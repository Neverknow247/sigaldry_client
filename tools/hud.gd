extends Control

@onready var screen_name_label: Label = $screen_name_label
@onready var standard_number: Label = $resources/materials/standard_materials/standard_number
@onready var premium_number: Label = $resources/materials/premium_materials/premium_number

func _ready() -> void:
	pass

func update_player(payload):
	print(payload)
	if payload:
		set_screen_name(payload["screen_name"])
		standard_number.text = str(int(payload["standard_currency"]))
		premium_number.text = str(int(payload["premium_currency"]))

func set_screen_name(_screen_name):
	#var font_size = 20
	#match _screen_name.length():
		#14: font_size = 22
		#13: font_size = 24
		#12: font_size = 26
		#11: font_size = 28
		#10: font_size = 31
		#9: font_size = 34
		#8: font_size = 38
		#_:
			#pass
	#if _screen_name.length() < 8:
		#font_size = 40
	#screen_name_label.add_theme_font_size_override("font_size",font_size)
	screen_name_label.text = _screen_name

func _on_back_button_pressed() -> void:
	pass # Replace with function body.
