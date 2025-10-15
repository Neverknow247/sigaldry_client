extends Control

var scene_name = "card_name_edit"

var stats = Stats
var KEYWORD_GLOSS = KeyWordGlossary

signal back_to_editor
signal validate_card_name(_data)
signal save_card_name(_data)

@onready var background_color: ColorRect = $background_color
@onready var card_preview: Control = $card_preview
@onready var name_edit: LineEdit = $name_edit
@onready var validate_button: Button = $buttons_container/validate_button
@onready var submit_button: Button = $buttons_container/submit_button

var card_id = null
var card_name = null
var validation_code = null

func _ready():
	background_color.color = stats.background_color

func reset():
	name_edit.text = ""
	validate_button.disabled = true
	submit_button.disabled = true
	card_id = null
	card_name = null
	validation_code = null

func _on_back_button_pressed() -> void:
	back_to_editor.emit()
	reset()

func _on_line_edit_text_changed(new_text: String) -> void:
	card_name = new_text
	validation_code = null
	submit_button.disabled = true
	check_validate()

func check_validate():
	if name_edit.text.length() > 1:
		validate_button.disabled = false
	else:
		validate_button.disabled = true

func _on_validate_button_pressed() -> void:
	validate_card_name.emit({"card_id":card_id,"name":card_name})

func card_name_validated(payload):
	validation_code = payload["validation_code"]
	submit_button.disabled = false

func _on_submit_button_pressed() -> void:
	save_card_name.emit({"card_id":card_id,"name":card_name,"validation_code":validation_code})
	#reset()
	_on_back_button_pressed()

func get_info_card_name_edit(payload):
	show()
	print(payload)
	card_id = payload["def"]["id"]
	card_preview.add_details(payload["def"])
	card_preview.show()
