extends RichTextLabel

var KEYWORD_GLOSS = KeyWordGlossary

func _ready():
	bbcode_enabled = true
	connect("meta_clicked", _on_clicked)

func _on_clicked(meta_data):
	Utils.spawn_tooltips_on_mouse(meta_data)
