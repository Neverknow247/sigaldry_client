extends Control

var stats = Stats

@onready var screen_name_label: Label = $screen_name_label
@onready var standard_number: Label = $resources/materials/standard_materials/standard_number
@onready var premium_number: Label = $resources/materials/premium_materials/premium_number
@onready var back_button: Button = $h_box_container/back_button
@onready var settings_dropdown: PopupMenu = $settings_dropdown

signal back
signal logout
signal concede

func _ready() -> void:
	reset_settings()

func reset_settings():
	settings_dropdown.clear()
	settings_dropdown.size.y = 0
	settings_dropdown.add_item("Settings",3)
	settings_dropdown.add_item("Logout",1)
	settings_dropdown.add_item("Quit",0)

func update_player(payload):
	#print(payload)
	if payload:
		set_screen_name(payload["screen_name"])
		standard_number.text = str(int(payload["standard_currency"]))
		premium_number.text = str(int(payload["premium_currency"]))

func update_scene(new_scene_name):
	back_button.text = "Main Menu"
	back_button.show()
	print("NEW SCENE NAME: ",new_scene_name)
	match new_scene_name:
		"wrong_version","login","register","menu","card_select":
			back_button.hide()
		"deck_select","waiting":
			back_button.text = "Cancel"
		"game":
			print("heyyyy")
			back_button.hide()
			settings_dropdown.clear()
			settings_dropdown.add_item("Settings",3)
			settings_dropdown.add_item("Concede",10)
			settings_dropdown.add_item("Logout",1)
			settings_dropdown.add_item("Quit",0)
			#settings_dropdown.
		"game_finished":
			reset_settings()
			#settings_dropdown.remove_item(settings_dropdown.get_item_index(10))
		_:
			back_button.show()

func set_screen_name(_screen_name):
	screen_name_label.text = _screen_name

func _on_back_button_pressed() -> void:
	back.emit()

func _on_settings_button_pressed() -> void:
	settings_dropdown.show()

func _on_settings_dropdown_index_pressed(index: int) -> void:
	print("DROP DOWN SELECT: ",settings_dropdown.get_item_text(index))
	match settings_dropdown.get_item_text(index):
		"Settings":
			pass
		"Logout":
			stats["save_data"]["remember_me"]["username"] = ""
			stats["save_data"]["remember_me"]["password"] = ""
			SaveAndLoad.save_all()
			logout.emit()
		"Quit":
			logout.emit()
			get_tree().quit()
		"Concede":
			concede.emit()
	print(index)
