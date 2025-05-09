extends TextureRect

const avatar_texture = preload("res://assets/art/card_template_avatar.png")

@onready var card_name = $card_name
@onready var card_effects = $card_effects
@onready var card_type = $card_type
@onready var card_price = $card_price
@onready var card_attack = $card_attack
@onready var card_health = $card_health
#@onready var card_color_profile = $card_color_profile

@onready var card_color_profile = $card_color_profile

@onready var in_deck_ui = $in_deck_ui
@onready var not_in_deck_ui = $not_in_deck_ui
@onready var unit_not_in_deck_ui = $unit_not_in_deck_ui
@onready var unit_only_add_avatar = $unit_only_add_avatar
@onready var card_select_button = $card_select_button
@onready var game_card_select_ui = $game_card_select_ui
@onready var card_select = $game_card_select_ui/card_select
@onready var builder_compare_select_ui = $builder_compare_select_ui

var type = ""
var source_type = ""
var card_id = 0

signal remove_from_deck(id)
signal add_avatar_to_deck(id)
signal add_to_deck(id)
signal select_card(id)
signal add_avatar_to_new_deck(id)
@warning_ignore("unused_signal")
signal game_pressed
signal get_info(data)
signal compare_card(id)

func activate_avatar():
	texture = avatar_texture

func _on_mouse_entered():
	if type == "in_deck":
		in_deck_ui.show()
	elif type == "not_in_deck":
		not_in_deck_ui.show()
	elif type == "unit_not_in_deck":
		unit_not_in_deck_ui.show()
	elif type == "card_select":
		card_select_button.show()
	elif type == "game_type":
		game_card_select_ui.show()
	elif type == "unit_only":
		unit_only_add_avatar.show()
	elif type == "builder_compare":
		builder_compare_select_ui.show()
	else:
		pass

func _on_mouse_exited():
	in_deck_ui.hide()
	not_in_deck_ui.hide()
	unit_not_in_deck_ui.hide()
	unit_only_add_avatar.hide()
	#builder_compare_select_ui.hide()

func _on_remove_button_pressed():
	if card_id:
		remove_from_deck.emit(card_id)

func _on_add_avatar_button_pressed():
	add_avatar_to_deck.emit(card_id)

func _on_add_unit_only_avatar_button_pressed():
	add_avatar_to_new_deck.emit(card_id)

func _on_add_button_pressed():
	if card_id:
		add_to_deck.emit(card_id)

func _on_card_select_button_pressed():
	select_card.emit(card_id)

func _on_game_card_select_ui_focus(_focus):
	if _focus == true:
		print(card_id)
		#focused_card.emit()
		#select_card.emit(card_id)
	else:
		pass


signal mouse_focus(_pos,_focus,card_id,source_type)

func _on_card_select_mouse_entered():
	mouse_focus.emit(global_position,true,card_id,source_type)

func _on_card_select_mouse_exited():
	mouse_focus.emit(global_position,false,card_id,source_type)

func _on_card_select_get_info():
	get_info.emit({"type":"card","id":card_id})

func _on_compare_card_select_pressed():
	print("Selected Card ID: ", card_id)
	compare_card.emit(card_id)
