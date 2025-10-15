extends Node
#class_name CardArtCache
##
## CardArtCache — Godot 4.4.1
## - RAM LRU + Disk cache for card textures
## - Compatible with your existing server API (7 endpoints)
## - Works with base64 data URLs and raw bytes
## - Queue with limited parallel fetches
## - Exposes hooks for sending requests and routing responses
##

# -----------------------------
# Config
# -----------------------------
const CACHE_DIR := "user://card_cache"
var INDEX_PATH := CACHE_DIR.path_join("index.json")

# RAM cache (textures) — keep hot items small to avoid VRAM spikes
const MAX_RAM_ITEMS := 256

# Disk cache budget and aging
const MAX_DISK_BYTES := 250 * 1024 * 1024    # 250 MB
const MAX_FILE_AGE_SEC := 24 * 3600          # 24h

# If true, disk cache is wiped when leaving a match
var EPHEMERAL_MODE: bool = false

# Fetch pipeline tuning
const MAX_PARALLEL_FETCHES := 4
const REQUEST_TIMEOUT_SEC := 15.0

# -----------------------------
# State
# -----------------------------
# RAM LRU
var _ram_lru: Dictionary = {}            # key -> { texture:Texture2D, last_use:int }
var _ram_order: Array[String] = []       # queue of keys (oldest at 0)

# Disk index
var _index: Dictionary = {}              # key -> { file:String, size:int, last_use:int }

# Fetch queue and inflight tracking
var _queue: Array[String] = []
var _in_flight: Dictionary = {}          # key -> true

# Network hook (must be provided by the game)
# A Callable that takes (request: Dictionary) and sends it to your server.
# It should NOT block. When the response arrives, your network code must call
# CardArtCache.route_server_message(response_dict).
var _send_request: Callable = Callable()

# -----------------------------
# Signals
# -----------------------------
signal image_file_received(image_key: String, ok: bool, encoding: String, payload)  # raw payload as received
signal texture_ready(image_key: String, texture: Texture2D)                          # emitted when texture enters RAM

# -----------------------------
# Lifecycle
# -----------------------------
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(CACHE_DIR)
	_load_index()

# -----------------------------
# External Integration
# -----------------------------

## Provide a function that will send a request to your server.
## Example: set_request_sender(func(req): Global.net.send(req))
func set_request_sender(sender: Callable) -> void:
	_send_request = sender

## Route raw responses from your network layer to this cache.
## Call this from your global network handler.
## The response is expected to look like:
## { "type": "<server-response-type>", "data": {...} }
func route_server_message(response: Dictionary) -> void:
	if typeof(response) != TYPE_DICTIONARY: return
	if not response.has("type"): return
	var t := String(response.type)
	var d = response.get("data", {})

	match t:
		"get-card-image-files":
			# unified response shape for single/multi fetches
			if typeof(d) == TYPE_DICTIONARY and d.has("files") and typeof(d.files) == TYPE_ARRAY:
				for f in d.files:
					_process_file_payload(f)
		"get-card-image-keys":
			# owned/accessible keys list
			if typeof(d) == TYPE_DICTIONARY and d.has("keys") and typeof(d.keys) == TYPE_ARRAY:
				# No auto-fetch here; expose to caller via return/flow, or they can call sync_owned_keys()
				# (We don't emit a signal here to avoid coupling; up to you to use sync helpers below.)
				pass
		"get-opponent-card-image-keys":
			# auto-process like owned keys, but this arrives only during a game
			if typeof(d) == TYPE_DICTIONARY and d.has("keys") and typeof(d.keys) == TYPE_ARRAY:
				var keys: PackedStringArray = PackedStringArray(d.keys)
				ensure_keys(keys, true)
		_:
			# other server messages are ignored
			pass

# -----------------------------
# Public API (Cache Control)
# -----------------------------

func set_ephemeral_mode(on: bool) -> void:
	EPHEMERAL_MODE = on

## Ensure a list of keys is cached (RAM or disk). Any missing ones will be queued for download.
## prefer_raw = true tries to receive raw bytes (if server supports).
func ensure_keys(keys: PackedStringArray, prefer_raw: bool = true) -> void:
	for key in keys:
		if _has_in_ram(key): continue
		if _has_on_disk(key): continue
		if _in_flight.has(key): continue
		_queue.append(key)
	_pump_queue(prefer_raw)

## Get a texture immediately if cached; otherwise enqueue fetch and return placeholder.
func get_texture(key: String, placeholder: Texture2D = null) -> Texture2D:
	var tex := _get_from_ram(key)
	if tex: return tex

	tex = _load_from_disk(key)
	if tex: return tex

	# Not available: enqueue single fetch
	if not _in_flight.has(key):
		_queue.append(key)
		_pump_queue(true)
	return placeholder

## Wait for a texture with a timeout. Returns placeholder if not ready in time.
## Note: This does not block the main thread; it yields frames.
func get_texture_async(key: String, placeholder: Texture2D = null, prefer_raw: bool = true) -> Texture2D:
	if key == "<null>":
		return placeholder
	var tex := get_texture(key, placeholder)
	if tex != placeholder:
		return tex

	var t0 := Time.get_unix_time_from_system()
	while (Time.get_unix_time_from_system() - t0) < REQUEST_TIMEOUT_SEC:
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
			DirAccess.remove_absolute(CACHE_DIR.path_join(name))
		dir.list_dir_end()
	_index.clear()
	_save_index()

func prune_disk_cache() -> void:
	var now := Time.get_unix_time_from_system()
	var total := 0
	var entries: Array = []

	var dir := DirAccess.open(CACHE_DIR)
	if dir == null: return

	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name == "": break
		if name.ends_with(".json"): continue
		var path := CACHE_DIR.path_join(name)
		var size
		var file := FileAccess.open(path, FileAccess.READ)
		if file:
			size = file.get_length()
			file.close()
		total += int(size)
		var key := _find_key_by_file(name)
		var last_use := 0
		if key != "":
			last_use = int(_index.get(key, {}).get("last_use", 0))
		# Age-out
		if (MAX_FILE_AGE_SEC > 0) and ((now - last_use) > MAX_FILE_AGE_SEC):
			DirAccess.remove_absolute(path)
			if key != "": _index.erase(key)
		else:
			entries.append({
				"key": key, "path": path, "size": int(size), "last_use": int(last_use)
			})
	dir.list_dir_end()

	# recompute total
	total = 0
	for e in entries: total += int(e.size)

	# Size trim (LRU by last_use)
	if total > MAX_DISK_BYTES:
		entries.sort_custom(func(a, b): return int(a.last_use) < int(b.last_use))
		for e in entries:
			if total <= MAX_DISK_BYTES: break
			DirAccess.remove_absolute(String(e.path))
			if String(e.key) != "": _index.erase(String(e.key))
			total -= int(e.size)

	_save_index()

## Call this at match end.
func on_leave_match() -> void:
	clear_ram_cache()
	if EPHEMERAL_MODE:
		wipe_disk_cache()
	else:
		prune_disk_cache()

# -----------------------------
# Public API (Server Sync Helpers)
# -----------------------------

## Ask server for list of all keys you own, compare with disk index, and queue missing.
func sync_owned_keys(prefer_raw: bool = true) -> void:
	# Request keys; when your network receives the response ("get-card-image-keys"),
	# call route_server_message(), which does not auto-fetch by design.
	# To make this helper autonomous, we chain a one-shot waiter:
	var waiter = await _request_with_wait("get-card-image-keys", {})
	if waiter == null: return
	_process_after(await waiter, prefer_raw)

## Ask server for opponent deck keys (valid only during a game). Queues missing.
func sync_opponent_keys(prefer_raw: bool = true) -> void:
	# Server auto-sends "get-opponent-card-image-keys" on game start, but this is a manual trigger.
	var waiter = await _request_with_wait("get-opponent-card-image-keys", {})
	if waiter == null: return
	# In route_server_message we already auto-ensure_keys() for opponent keys, so nothing else needed here.
	await waiter

# -----------------------------
# Internal: Request/Response
# -----------------------------

## Push queued keys into inflight up to MAX_PARALLEL_FETCHES
func _pump_queue(prefer_raw: bool) -> void:
	while _in_flight.size() < MAX_PARALLEL_FETCHES and _queue.size() > 0:
		var key = _queue.pop_front()
		if _in_flight.has(key): continue
		_in_flight[key] = true
		_request_image_file_from_key(key, prefer_raw)

## Build and send a single-file request for a given key.
func _request_image_file_from_key(image_key: String, prefer_raw: bool = true) -> void:
	var req := {
		"type": "get-card-image-file-from-key",
		"data": {
			"image_key": image_key,
			# Per server docs: "base64" (default) OR anything else to return raw buffer
			"encoding": prefer_raw if "" else "base64"
		}
	}
	_safe_send(req)

## Handle an individual file object in a "files" response array.
## Expects:
## {
##   image_key: "file.png",
##   image_file: "<data-url-or-bytes>",
##   encoding: "base64" | (anything else for raw bytes)
## }
func _process_file_payload(file_obj: Dictionary) -> void:
	var image_key := String(file_obj.get("image_key", ""))
	if image_key == "":
		return

	var encoding := String(file_obj.get("encoding", "base64"))
	var payload = file_obj.get("image_file")

	var ok := payload != null
	emit_signal("image_file_received", image_key, ok, encoding, payload)
	_in_flight.erase(image_key)

	if not ok:
		return

	var bytes := _coerce_image_bytes(payload, encoding)
	if bytes.is_empty():
		push_warning("Empty/invalid image payload for %s" % image_key)
		return

	var fname := _safe_filename_from_key(image_key)
	var path := CACHE_DIR.path_join(fname)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_warning("Failed to write cache file %s" % path)
		return
	f.store_buffer(bytes)
	f.close()

	var tex := _load_texture_from_file(path)
	if tex:
		_touch_ram(image_key, tex)
		var size
		var file := FileAccess.open(path, FileAccess.READ)
		if file:
			size = file.get_length()
			file.close()
		_touch_disk(image_key, fname, size)
		emit_signal("texture_ready", image_key, tex)
	else:
		DirAccess.remove_absolute(path)

	# keep the pipeline going
	_pump_queue(true)

# Convert server payload to PackedByteArray bytes.
# - If encoding == "base64", we accept either:
#   - full data URLs "data:image/png;base64,AAAA..."
#   - bare base64 "AAAA..."
# - Otherwise, we expect raw bytes (or string that we treat as base64 as a fallback).
func _coerce_image_bytes(payload, encoding: String) -> PackedByteArray:
	var out := PackedByteArray()

	if encoding == "base64":
		if typeof(payload) == TYPE_STRING:
			var s := String(payload)
			var comma := s.find(",")
			if comma >= 0 and s.begins_with("data:"):
				s = s.substr(comma + 1)  # strip "data:image/...;base64,"
			out = Marshalls.base64_to_raw(s)
		elif typeof(payload) == TYPE_PACKED_BYTE_ARRAY:
			# Some servers wrap base64 bytes again; accept as-is
			out = payload
		else:
			push_warning("Unexpected base64 payload type: %s" % typeof(payload))
	else:
		# raw branch
		if typeof(payload) == TYPE_PACKED_BYTE_ARRAY:
			out = payload
		elif typeof(payload) == TYPE_STRING:
			# If "raw" arrived as string, it might still be base64 (transport limitation). Try decoding.
			var s2 := String(payload)
			# Attempt data URL strip if present
			var comma2 := s2.find(",")
			if comma2 >= 0 and s2.begins_with("data:"):
				s2 = s2.substr(comma2 + 1)
			out = Marshalls.base64_to_raw(s2)
		else:
			push_warning("Unexpected raw payload type: %s" % typeof(payload))

	return out

# -----------------------------
# Internal: Texture + Disk Index + RAM LRU
# -----------------------------

func _load_texture_from_file(path: String) -> Texture2D:
	var img := Image.new()
	var err := img.load(path)
	if err != OK:
		push_warning("Image.load failed for %s (err=%s)" % [path, str(err)])
		return null
	return ImageTexture.create_from_image(img)

func _get_from_ram(key: String) -> Texture2D:
	if _ram_lru.has(key):
		_touch_ram(key, _ram_lru[key].texture)
		return _ram_lru[key].texture
	return null

func _has_in_ram(key: String) -> bool:
	return _ram_lru.has(key)

func _has_on_disk(key: String) -> bool:
	if not _index.has(key): return false
	var fname := String(_index[key].get("file", ""))
	if fname == "": return false
	return FileAccess.file_exists(CACHE_DIR.path_join(fname))

func _load_from_disk(key: String) -> Texture2D:
	if not _has_on_disk(key): return null
	var fname := String(_index[key].file)
	var path := CACHE_DIR.path_join(fname)
	var tex := _load_texture_from_file(path)
	if tex:
		_touch_ram(key, tex)
		var size
		var file := FileAccess.open(path, FileAccess.READ)
		if file:
			size = file.get_length()
			file.close()
		_touch_disk(key, fname, size)
		emit_signal("texture_ready", key, tex)
		return tex
	# File corrupt or unreadable
	DirAccess.remove_absolute(path)
	_index.erase(key)
	_save_index()
	return null

func _touch_ram(key: String, tex: Texture2D) -> void:
	var now := Time.get_unix_time_from_system()
	if _ram_lru.has(key):
		_ram_order.erase(key)
	_ram_lru[key] = { "texture": tex, "last_use": now }
	_ram_order.append(key)
	if _ram_order.size() > MAX_RAM_ITEMS:
		var evict_key: String = _ram_order.pop_front()
		_ram_lru.erase(evict_key)

func _touch_disk(key: String, fname: String, size: int) -> void:
	_index[key] = { "file": fname, "size": int(size), "last_use": Time.get_unix_time_from_system() }
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
		if String(_index[k].get("file", "")) == fname:
			return String(k)
	return ""

func _safe_filename_from_key(key: String) -> String:
	var ext := ""
	var dot := key.rfind(".")
	if dot != -1:
		ext = key.substr(dot)  # includes dot
	var h := HashingContext.new()
	h.start(HashingContext.HASH_MD5)
	h.update(key.to_utf8_buffer())
	var md5 := h.finish().hex_encode()
	return md5 + ext

# -----------------------------
# Internal: Request helpers
# -----------------------------

func _safe_send(req: Dictionary) -> void:
	if not _send_request.is_valid():
		push_warning("CardArtCache: request sender not set; call set_request_sender()")
		return
	# Your sender should NOT block and should deliver the response later to route_server_message()
	_send_request.call(req)

# Fire a request and wait for the matching response type within REQUEST_TIMEOUT_SEC.
# Returns the response Dictionary or null on timeout/failure.
func _request_with_wait(req_type: String, data: Dictionary):
	if not _send_request.is_valid():
		push_warning("CardArtCache: request sender not set; call set_request_sender()")
		return null

	var awaited_type := req_type.replace("-request", "").strip_edges()
	# Map request -> expected response type
	var expected = req_type
	#var expected = match req_type:
		#"get-card-image-keys": "get-card-image-keys"
		#"get-opponent-card-image-keys": "get-opponent-card-image-keys"
		#_: req_type  # generic fallback

	var result: Dictionary = {}
	var got := false

	# local hook to intercept the next matching message
	var hook := func(resp: Dictionary) -> void:
		if typeof(resp) == TYPE_DICTIONARY and resp.get("type", "") == expected:
			result = resp
			got = true

	# We can't globally subscribe here, so the app should call route_server_message(resp).
	# We'll poll for a short window.
	_safe_send({"type": req_type, "data": data})

	return await _wait_for_response(expected, func()->bool: return got, func()->Dictionary: return result)

# Internal polling wait pattern with timeout.
func _wait_for_response(expected_type: String, got_func: Callable, get_result: Callable):
	return await _wait_coroutine(expected_type, got_func, get_result)

#async function
func _wait_coroutine(expected_type: String, got_func: Callable, get_result: Callable) -> Dictionary:
	var t0 := Time.get_unix_time_from_system()
	while (Time.get_unix_time_from_system() - t0) < REQUEST_TIMEOUT_SEC:
		await get_tree().process_frame
		if bool(got_func.call()):
			return get_result.call()
	return {}
	
# -----------------------------
# Post-request processor for owned keys sync
# -----------------------------
func _process_after(response: Dictionary, prefer_raw: bool) -> void:
	if typeof(response) != TYPE_DICTIONARY: return
	if response.get("type", "") != "get-card-image-keys": return
	var d = response.get("data", {})
	if typeof(d) != TYPE_DICTIONARY or not d.has("keys"): return
	var keys: PackedStringArray = PackedStringArray(d.keys)
	# Compare to disk and enqueue missing
	var missing: PackedStringArray = []
	for k in keys:
		if _has_in_ram(k): continue
		if _has_on_disk(k): continue
		missing.append(k)
	if missing.size() > 0:
		ensure_keys(missing, prefer_raw)
