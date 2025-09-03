extends Control

var scene_name = "card_editor"

var stats = Stats
var KEYWORD_GLOSS = KeyWordGlossary

const CARD_SCENE = preload("res://items/card.tscn")
const CARD_EDITOR_CARD_SELECT = preload("res://card_builder_scenes/card_editor_card_select.tscn")

signal back_to_menu
signal imagegen_get_unit_classes_and_races(_card_id)
signal imagegen_make_unit_image(_data)

@onready var background_color: ColorRect = $background_color
@onready var v_box_container: VBoxContainer = $scroll_container/v_box_container
@onready var card_image_edit: Control = $card_image_edit
@onready var card_name_edit: Control = $card_name_edit

var changing_scene = false
var binder_width = 3

func _ready():
	background_color.color = stats.background_color

func reset_editor():
	card_image_edit.hide()
	card_name_edit.hide()
	changing_scene = false

func _on_back_button_pressed() -> void:
	reset_editor()
	back_to_menu.emit()

func add_cards(payload):
	#print(payload)
	for n in v_box_container.get_children():
		v_box_container.remove_child(n)
		n.queue_free()
	var card_number = 0
	var row_node
	var first_card = true
	for card in payload["cards"]:
		if card["meta"]["designer"]["user_id"] != card["meta"]["owner"]["user_id"]:
			continue
		if first_card:
			first_card = false
		if card_number == 0:
			row_node = HBoxContainer.new()
			v_box_container.add_child(row_node)
			row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			row_node.add_theme_constant_override("separation", 25)
		var new_card_editor_card = CARD_EDITOR_CARD_SELECT.instantiate()
		row_node.add_child(new_card_editor_card)
		new_card_editor_card.add_card(card)
		new_card_editor_card.connect("start_add_card_image",start_add_card_image)
		new_card_editor_card.connect("start_add_card_name",start_add_card_name)
		card_number+=1
		if card_number == binder_width:
			card_number = 0

func start_add_card_image(card_id):
	if !changing_scene:
		changing_scene = true
		imagegen_get_unit_classes_and_races.emit(card_id)
	
func start_card_image_editor(payload):
	card_image_edit.show()
	card_image_edit.set_classes_and_races(payload)

func start_add_card_name(card_id):
	if !changing_scene:
		changing_scene = true
		print("card name start")

func start_card_name_editor(payload):
	card_name_edit.show()

func _on_card_image_edit_back_to_editor() -> void:
	changing_scene = false
	card_image_edit.hide()

func _on_card_image_edit_imagegen_make_unit_image(_data: Variant) -> void:
	imagegen_make_unit_image.emit(_data)
