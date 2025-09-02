extends RichTextLabel

var KEYWORD_GLOSS = KeyWordGlossary

@export var custom_tooltip_scene: PackedScene

@onready var labels = $labels

func _ready():
	bbcode_enabled = true
	connect("meta_hover_started", _on_meta_hover_started)
	connect("meta_hover_ended", _on_meta_hover_ended)

func _make_custom_tooltip(for_text):
	var tooltip_instance =  custom_tooltip_scene.instantiate()
	var tooltip_label =  tooltip_instance.find_child("tooltip_rich_text_label")
	
	if for_text in KEYWORD_GLOSS.glossary:
		print(KEYWORD_GLOSS.glossary[for_text])
		tooltip_label.text = KEYWORD_GLOSS.glossary[for_text]
	else:
		print("UNKNOWN")
		tooltip_label.text = "UNKNOWN"
		return
	
	return tooltip_instance

func _on_meta_hover_started(meta_data):
	var new_tooltip =  _make_custom_tooltip(meta_data) as Control
	labels.add_child(new_tooltip)
	new_tooltip.set_anchors_preset(Control.PRESET_FULL_RECT)
	#Input.mouse_mode  =  Input.MOUSE_MODE_HIDDEN
	#print("Hover Started Over: ", meta_data)

func _on_meta_hover_ended(meta_data):
	for child in labels.get_children():
		labels.remove_child(child)
		child.queue_free()
	Input.mouse_mode  =  Input.MOUSE_MODE_VISIBLE
	#print("Hover Ended Over: ", meta_data)
