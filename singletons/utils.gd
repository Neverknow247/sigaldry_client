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

var persistant_popups = true

func spawn_tooltips_on_mouse(meta_data):
	var tooltip_instance =  TOOLTIP_SCENE.instantiate()
	var tooltip_label =  tooltip_instance.find_child("tooltip_rich_text_label")
	var tooltip_text = ""
	if meta_data in KeyWordGlossary.key_glossary:
		var words = KeyWordGlossary.key_glossary[meta_data]["description"].split(" ")
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
				tooltip_text += "[url=" + dependent_key + "]" + \
				dependent_keyword.capitalize() + "[/url]" + " "
			else:
				tooltip_text += word + " "
		tooltip_label.text = tooltip_text
		#for key in KeyWordGlossary.key_glossary[meta_data]["dependencies"]:
			#print(key)
			#print(KeyWordGlossary.key_glossary[key]["name"])
	else:
		print("UNKNOWN")
		tooltip_label.text = "UNKNOWN"
		return
	var current_scene = get_tree().get_current_scene()
	if current_scene.is_in_group("client"):
		current_scene.tooltips.add_child(tooltip_instance)
	tooltip_instance.window.position = get_tree().current_scene.get_global_mouse_position()
	if tooltip_instance.window.position.x > 1920 - 736:
		tooltip_instance.window.position.x = 1920 - 736
	if tooltip_instance.window.position.y > 1080 - 136:
		tooltip_instance.window.position.y = 1080 - 136
	tooltip_instance.z_index = 100
	tooltip_instance.set_up_size()
	tooltip_instance.window.title = KeyWordGlossary.key_glossary[meta_data]["name"].capitalize()

func clear_tooltips():
	if !persistant_popups:
		for child in tooltips.get_children():
			tooltips.remove_child(child)
			child.queue_free()

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
	
