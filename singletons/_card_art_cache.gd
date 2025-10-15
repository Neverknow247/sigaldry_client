extends Node

#class_name CardArtCache

const CACHE_DIR := "user://card_cache"
const INDEX_PATH := CACHE_DIR + "/index.json"

const MAX_RAM_ITEMS := 256
const MAX_DISK_BYTES := 250 * 1024 * 1024
const MAX_FILE_AGE_SEC := 24 * 3600
var EPHEMERAL_MODE := false

const MAX_PARALLWL_FETCHES := 4
const REQUEST_TIMEOUT_SEC := 15

var _ram_lru: Dictionary = {}
var _ram_order: Array = []
var _index: Dictionary = {}
var _queue: Array[String] = []
var _in_flight: Dictionary = {}

signal image_file_received(image_key: String, ok: bool, encoding: String, payload)

var _http := HTTPRequest.new()

func _ready() -> void:
	add_child(_http)
	DirAccess.make_dir_recursive_absolute(CACHE_DIR)
	_load_index()

func set_ephemeral_mode(on: bool) -> void:
	EPHEMERAL_MODE = on

func ensure_keys(keys: PackedStringArray, prefer_raw: bool = true) -> void:
	for key in keys:
		if _has_in_ram(key): continue
		if _has_on_disk(key): continue
		if _in_flight.has(key): continue
		_queue.append(key)
	_pump_queue(prefer_raw)

func get_texture(key: String, placeholder: Texture2D = null) -> Texture2D:
	var tex := _get_from_ram(key)
	if tex: return tex
	tex = _load_from_disk(key)
	if tex: return tex
	if not _in_flight.has(key):
		_queue.append(key)
		_pump_queue(true)
	return placeholder

func get_texture_async(key: String, placeholder: Texture2D = null, prefer_raw: bool = true) -> Texture2D:
	var tex := get_texture(key, placeholder)
	if tex != placeholder:
		return tex
	var t0 := Time.get_unix_time_from_system()
	while Time.get_unix_time_from_system() - t0 < REQUEST_TIMEOUT_SEC:
		await get_tree().process_frame
		tex = _get_from_ram(key)
		if tex and tex != placeholder:
			return tex
	return placeholder

func clear_ram_cache() -> void:
	_ram_lru.clear()
	_ram_order.clear()

func wipe_disk_cache() -> void:
	var dir := DirAccess.open(CACHE_DIR)
	if dir:
		dir.list_dir_begin()
		while true:
			var name := dir.get_next()
			if name == "": break
			if name.ends_with(".json"): continue
			DirAccess.remove_absolute(CACHE_DIR + "/" + name)
		dir.list_dir_end()
	_index.clear()
	_save_index()

func prune_disk_cache() -> void:
	var now := Time.get_unix_time_from_system()
	var total := 0
	var entries : Array = []
	var dir := DirAccess.open(CACHE_DIR)
	if dir == null: return
	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name == "": break
		if name.ends_with(".json"): continue
		var path := CACHE_DIR + "/" + name
		var size := FileAccess.get_file_len(path)
		total += size
		var key := _find_key_by_file(name)
		var last_use := 0
		if key != "":
			last_use = int(_index.get(key, {}).get("last_use",0))
		if MAX_FILE_AGE_SEC > 0 and (now - last_use) > MAX_FILE_AGE_SEC:
			DirAccess.remove_absolute(path)
			if key != "": _index.erase(key)
		else:
			entries.append({"key":key, "path":path, "size":size, "last_use": last_use})
	dir.list_dir_end()
	total = 0
	for e in entries: total += int(e.size)
	if total > MAX_DISK_BYTES:
		entries.sort_custom(func(a,b): return int(a.last_use) < int(b.last_use))
		for e in entries:
			if total <= MAX_DISK_BYTES: break
			DirAccess.remove_absolute(String(e.path))
			if String(e.key) != "": _index.erase(String(e.key))
			total -= int(e.size)
	_save_index()

func on_leave_match() -> void:
	clear_ram_cache()
	if EPHEMERAL_MODE:
		wipe_disk_cache()
	else:
		prune_disk_cache()

func request_image_file_from_key(image_key: String, prefer_raw: bool = true) -> void:
	var encoding = prefer_raw if "raw" else "base64"
	var req := {
		"type": "get-card-image-file-from-key",
		"data": {
			"image_key": image_key,
			"encoding": prefer_raw if "" else "base64"
		}
	}
	#Send to client here
	#Global.network.send_request(req, func(response):
		#if response.has("files") and response.files.size() > 0:
			#var file = response.files[0]
			#_on_image_file_received(file.image_key, true, file.encoding, file.image_file)
		#else:
			#_on_image_file_received(image_key, false, "", null)

func _pump_queue(prefer_raw: bool) -> void:
	while _in_flight.size() < MAX_PARALLWL_FETCHES and _queue.size() > 0:
		var key := _queue.pop_front()
		if _in_flight.has(key): continue
		_in_flight[key] = true
		request_image_file_from_key(key, prefer_raw)

func _on_image_file_received(image_key: String, ok: bool, encoding: String, payload) -> void:
	emit_signal("image_file_received",image_key, ok, encoding, payload)
	_in_flight.erase(image_key)
	if not ok:
		return
	var bytes := PackedByteArray()
	if encoding == "base64":
		if typeof(payload) == TYPE_STRING:
			bytes = Marshalls.base64_to_raw(payload)
		else:
			push_warning("Expected base64 string for %s" % image_key)
			return
	else:
		if typeof(payload) == TYPE_PACKED_BYTE_ARRAY:
			bytes = payload
		else:
			push_warning("Expected raw bytes for %s" % image_key)
			return
	var fname := _safe_filename_from_key(image_key)
	var path := "%s%s" % [CACHE_DIR, fname]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_warning("Failed to write cache file %s" % path)
		return
	f.store_buffer(bytes)
	f.close()
	var tex := _load_texture_from_file(path)
	if tex:
		_touch_ram(image_key, tex)
		_touch_disk(image_key, fname, FileAccess.get_file_len(path))
	else:
		DirAccess.remove_absolute(path)
	_pump_queue(true)

func load_texture_from_file(path: String) -> Texture2D:
	var img := Image.new()
	var err := img.load(path)
	if err != OK:
		push_warning("Image.load failed for %s" % path)
		return null
	var tex := ImageTexture.new()
	tex.set_image(img)
	return tex

func _get_from_ram(key: String) -> Texture2D:
	if _ram_lru.has(key):
		_touch_ram(key, _ram_lru[key].texture)
		return _ram_lru[key].texture
	return null

func _has_in_ram(key: String) -> bool:
	return _ram_lru.has(key)

func _has_on_disk(key: String) -> bool:
	if not _index.has(key): return false
	var fname = _index[key].get("file","")
	if fname == "": return false
	return FileAccess.file_exists("%s/%s" % [CACHE_DIR, fname])

func _load_from_disk(key: String) -> Texture2D:
	if not _has_on_disk(key): return null
	var fname := _index[key].file
	var path := "%s/%s" % [CACHE_DIR, fname]
	var tex := _load_texture_from_file(path)
	if tex:
		_touch_ram(key, tex)
		_touch_disk(key, fname, FileAccess.get_file_len(path))
		return tex
	DirAccess.remove_absolute(path)
	_index.erase(key)
	_save_index()
	return null

func _touch_ram(key: String, tex: Texture2D) -> void:
	var now := Time.get_unix_time_from_system()
	if _ram_lru.has(key):
		_ram_order.erase(key)
	_ram_lru[key] = { "texture": tex, "last_use": now}
	_ram_order.append(key)
	if _ram_order.size() > MAX_RAM_ITEMS:
		var evict_key = _ram_order.pop_front()
		_ram_lru.erase(evict_key)

func _touch_disk(key: String, fname: String, size: int) -> void:
	_index[key] = { "file": fname, "size": int(size), "last_use": Time.get_unix_time_from_system()}
	_save_index()

func _load_index() -> void:
	if FileAccess.file_exists(INDEX_PATH):
		var f := FileAccess.open(INDEX_PATH, FileAccess.READ)
		if f:
			var txt := f.get_as_text()
			f.close()
			if txt.length() > 0:
				var parsed = JSON.parse_string(txt)
				if typeof(parsed) == TYPE_DICTIONARY:
					_index = parsed
	if _index == null: _index = {}

func _save_index() -> void:
	var f := FileAccess.open(INDEX_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_index))
		f.close()

func _find_key_by_file(fname: String) -> String:
	for k in _index.keys():
		if _index[k].get("file", "") == fname:
			return k
	return ""

func _safe_filename_from_key(key: String) -> String:
	var ext := ""
	var dot := key.rfind(".")
	if dot != -1: ext = key.substr(dot)
	var h := HashingContext.new()
	h.start(HashingContext.HASH_MD5)
	h.update(key.to_utf8_buffer())
	var md5 := h.finish().hex_encode()
	return md5 + ext
