extends Control

var scene_name = "card_editor"

var stats = Stats
var KEYWORD_GLOSS = KeyWordGlossary

const CARD_SCENE = preload("res://items/card.tscn")
const CARD_EDITOR_CARD_SELECT = preload("res://card_builder_scenes/card_editor_card_select.tscn")

var binder_width = 3

@onready var background_color: ColorRect = $background_color
@onready var v_box_container: VBoxContainer = $scroll_container/v_box_container

signal back_to_menu

func _ready():
	background_color.color = stats.background_color

func _on_back_button_pressed() -> void:
	back_to_menu.emit()

func add_cards(payload):
	print(payload)
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
		new_card_editor_card.connect("add_card_image",add_card_image)
		new_card_editor_card.connect("add_card_name",add_card_name)
		card_number+=1
		if card_number == binder_width:
			card_number = 0

func add_card_image(card_id):
	pass

func add_card_name(card_id):
	pass
