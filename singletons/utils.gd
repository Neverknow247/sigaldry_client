extends Node

const TOOLTIP_SCENE = preload("res://items/tooltip.tscn")

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
