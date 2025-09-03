extends Control

var scene_name = "card_image_edit"

var stats = Stats
var KEYWORD_GLOSS = KeyWordGlossary

const CARD_SCENE = preload("res://items/card.tscn")

signal back_to_editor
signal imagegen_make_unit_image(_data)

@onready var background_color: ColorRect = $background_color
@onready var class_button: OptionButton = $class_button
@onready var race_button: OptionButton = $race_button
@onready var submit_button: Button = $submit_button

var card_id = null
var selected_class = null
var selected_race = null

func _ready():
	background_color.color = stats.background_color
	reset()

func reset():
	submit_button.disabled = true
	card_id = null
	selected_class = null
	selected_race = null
	class_button.clear()
	class_dictionary = {}
	race_button.clear()
	race_dictionary = {}
	class_button.add_item("Select A Class")
	race_button.add_item("Select A Race")

func _on_back_button_pressed() -> void:
	back_to_editor.emit()
	reset()

var class_dictionary = {}
var race_dictionary = {}

func set_classes_and_races(payload):
	card_id = payload["card_id"]
	var i = 0
	for _class in payload["classes"]:
		print("CLASS: ",_class)
		i+=1
		class_dictionary[i] = _class["id"]
		class_button.add_item(_class["name"],i)
	i = 0
	for _race in payload["races"]:
		print("RACE: ",_race)
		i+=1
		race_dictionary[i] = _race["id"]
		race_button.add_item(_race["name"],i)

func _on_class_button_item_selected(index: int) -> void:
	if index == -1:
		selected_class = null
	elif index > 0:
		selected_class = class_dictionary[index]
	check_submit()

func _on_race_button_item_selected(index: int) -> void:
	if index == -1:
		selected_race = null
	elif index > 0:
		selected_race = race_dictionary[index]
	check_submit()

func check_submit():
	if card_id != null and selected_class != null and selected_race != null:
		submit_button.disabled = false
		print("Selected Class: ",selected_class)
		print("Selected Race: ",selected_race)
	else:
		submit_button.disabled = true


func _on_submit_button_pressed() -> void:
	if card_id != null and selected_class != null and selected_race != null:
		imagegen_make_unit_image.emit({"card_id":card_id,"race":selected_race,"class":selected_class})
		_on_back_button_pressed()
