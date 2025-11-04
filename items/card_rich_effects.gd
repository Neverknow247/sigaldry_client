extends RichTextLabel

var KEYWORD_GLOSS = KeyWordGlossary

#@export var custom_tooltip_scene: PackedScene
var custom_tooltip_scene

#@onready var labels = $labels

func _ready():
	bbcode_enabled = true
	connect("meta_clicked", _on_clicked)
	custom_tooltip_scene = load("res://items/tooltip.tscn")
	#connect("meta_hover_started", _on_meta_hover_started)
	#connect("meta_hover_ended", _on_meta_hover_ended)

func _make_custom_tool(meta_data):
	#if custom_tooltip_scene == null:
		#print("null scene?")
		#custom_tooltip_scene = load("res://items/tooltip.tscn")
	var tooltip_instance =  custom_tooltip_scene.instantiate()
	var tooltip_label =  tooltip_instance.find_child("tooltip_rich_text_label")
	var tooltip_text = ""
	if meta_data in KEYWORD_GLOSS.key_glossary:
		var words = KeyWordGlossary.key_glossary[meta_data]["description"].split(" ")
		for word in words:
			var is_dependent = false
			var dependent_key
			for dependent in KeyWordGlossary.key_glossary[meta_data]["dependencies"]:
				if word == KeyWordGlossary.key_glossary[dependent]["name"]:
					is_dependent = true
					dependent_key = dependent
			if is_dependent:
				tooltip_text += "[url=" + dependent_key + "]" + \
				word.capitalize() + "[/url]" + " "
			else:
				tooltip_text += word + " "
		#tooltip_text = KeyWordGlossary.key_glossary[for_text]["description"]
		for key in KeyWordGlossary.key_glossary[meta_data]["dependencies"]:
			print(key)
			print(KeyWordGlossary.key_glossary[key]["name"])
		
		#[url=tooltip_data_1]hoverable word[/url]
		#effect_label.text = "[url=" + ability["key"] + "]" + \
				#ability["name"].capitalize() + "[/url]" + ": "
	
	
		#KEYWORD_GLOSS.glossary[ability["name"]]["description"]
		#print(KEYWORD_GLOSS.glossary[for_text])
		#tooltip_label.text = KEYWORD_GLOSS.glossary[for_text]
		#print(KeyWordGlossary.key_glossary[for_text]["description"])
		#tooltip_instance.set_up_text(KeyWordGlossary.glossary[for_text]["description"])
		#tooltip_label.text = KeyWordGlossary.key_glossary[for_text]["description"]
		tooltip_label.text = tooltip_text
		
	else:
		print("UNKNOWN")
		tooltip_label.text = "UNKNOWN"
		return
	
	return tooltip_instance

func _on_clicked(meta_data):
	var new_tooltip =  _make_custom_tool(meta_data) as Control
	
	var current_scene = get_tree().get_current_scene()
	if current_scene.is_in_group("client"):
		current_scene.tooltips.add_child(new_tooltip)
	#print(get_tree().current_scene.get_global_mouse_position())
	#new_tooltip.window.position = DisplayServer.mouse_get_position()
	#Vector2(650,50)
	#1920x1080
	
	new_tooltip.window.position = get_tree().current_scene.get_global_mouse_position()
	#new_tooltip.window.position = DisplayServer.mouse_get_position()
	if new_tooltip.window.position.x > 1920 - 736:
		new_tooltip.window.position.x = 1920 - 736
	if new_tooltip.window.position.y > 1080 - 136:
		new_tooltip.window.position.y = 1080 - 136
	new_tooltip.z_index = 100
	new_tooltip.set_up_size()
	new_tooltip.window.title = KeyWordGlossary.key_glossary[meta_data]["name"].capitalize()
	#new_tooltip.window.title = KeyWordGlossary.key_glossary[meta_data]["key"]
	#labels.add_child(new_tooltip)
	#new_tooltip.set_anchors_preset(Control.PRESET_FULL_RECT)
	#Input.mouse_mode  =  Input.MOUSE_MODE_HIDDEN
	#print("Hover Started Over: ", meta_data)

#func _on_meta_hover_ended(meta_data):
	#return
	#for child in labels.get_children():
		#labels.remove_child(child)
		#child.queue_free()
	#Input.mouse_mode  =  Input.MOUSE_MODE_VISIBLE
	#print("Hover Ended Over: ", meta_data)
