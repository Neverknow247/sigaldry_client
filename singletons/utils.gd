extends Node

const TOOLTIP_SCENE = preload("res://items/tooltip.tscn")

const AETHERGLACE_TUNDRA = preload("res://assets/art/background/aetherglace_tundra.png")
const ASHREND_STEPPE = preload("res://assets/art/background/ashrend_steppe.png")
const CRUCIBLE = preload("res://assets/art/background/crucible.png")
const DUNESMAR = preload("res://assets/art/background/dunesmar.png")
const EVERSPRING_VALE = preload("res://assets/art/background/everspring_vale.png")
const FLORENTIDE = preload("res://assets/art/background/florentide.png")
const SERAPHELLE = preload("res://assets/art/background/seraphelle.png")
const UMBRAVEIL = preload("res://assets/art/background/umbraveil.png")

var backgrounds = [
	AETHERGLACE_TUNDRA,ASHREND_STEPPE,CRUCIBLE,DUNESMAR,
	EVERSPRING_VALE,FLORENTIDE,SERAPHELLE,UMBRAVEIL
]

var tooltips
var open_tooltips: Dictionary = {}

var persistant_popups = true

const VOLUME_BUS_NAMES = {
	"master": "Master",
	"music": "Music",
	"voice": "Voice",
	"sfx": "Sounds",
}

var volume_settings = {
	"master": 1.0,
	"music": 1.0,
	"voice": 1.0,
	"sfx": 1.0,
}

func set_bus_volume(volume_key: String, linear_value: float):
	linear_value = clampf(linear_value, 0.0, 1.0)
	volume_settings[volume_key] = linear_value
	var bus_index = AudioServer.get_bus_index(VOLUME_BUS_NAMES[volume_key])
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_value))

func apply_volume_settings():
	for volume_key in volume_settings:
		set_bus_volume(volume_key, volume_settings[volume_key])

func spawn_tooltips_on_mouse(meta_data):
	if not meta_data in KeyWordGlossary.key_glossary:
		print("UNKNOWN")
		return
	if open_tooltips.has(meta_data) and is_instance_valid(open_tooltips[meta_data]):
		open_tooltips[meta_data].grab_focus()
		return
	var current_scene = get_tree().get_current_scene()
	if not current_scene.is_in_group("client"):
		return
	var glossary_entry = KeyWordGlossary.key_glossary[meta_data]
	var tooltip_text = ""
	var words = glossary_entry["description"].split(" ")
	for word in words:
		var is_dependent = false
		var dependent_keyword
		var dependent_key
		if word[0] == "<": #and word[word.length()-1] == ">":
			#var key = word.substr(1,word.length() - 2)
			var key = word.substr(1,word.length() - (word.length() - word.find(">")) -1)
			is_dependent = true
			dependent_key = key
			dependent_keyword = KeyWordGlossary.key_glossary[key]["name"]
		if is_dependent:
			tooltip_text += "[url=" + dependent_key + "][color=#f2ab37][u]" + \
			dependent_keyword.capitalize() + "[/u][/color][/url]" + " "
		else:
			tooltip_text += word + " "
		#for key in KeyWordGlossary.key_glossary[meta_data]["dependencies"]:
			#print(key)
			#print(KeyWordGlossary.key_glossary[key]["name"])
	var tooltip_instance = TOOLTIP_SCENE.instantiate()
	current_scene.tooltips.add_child(tooltip_instance)
	tooltip_instance.set_up_text(meta_data, glossary_entry["name"].capitalize(), tooltip_text)
	tooltip_instance.popup_centered_on_screen(open_tooltips.size())
	open_tooltips[meta_data] = tooltip_instance

func clear_tooltips():
	if !persistant_popups:
		for child in tooltips.get_children():
			tooltips.remove_child(child)
			child.queue_free()
		open_tooltips.clear()

func instantiate_scene_on_world(scene:PackedScene, position:Vector2):
	var world = get_tree().current_scene
	var instance = scene.instantiate()
	world.add_child(instance)
	instance.global_position = position
	return instance

func instantiate_popup_on_world(scene:PackedScene):
	var world = get_tree().current_scene
	var instance = scene.instantiate()
	world.add_child(instance)
	return instance

func random_background():
	var rand = Stats.rng.randi_range(0,backgrounds.size()-1)
	return backgrounds[rand]

func j_print(payload):
	print(JSON.stringify(payload, "\t"))
