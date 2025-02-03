extends TextureRect

@onready var card_name = $card_name
@onready var card_effects = $card_effects
@onready var card_price = $card_price
@onready var card_attack = $card_attack
@onready var card_health = $card_health

@onready var in_deck_ui = $in_deck_ui
@onready var not_in_deck_ui = $not_in_deck_ui

var type = ""
var card_id = 0

signal remove_from_deck(id)
signal add_to_deck(id)

func _on_mouse_entered():
	if type == "in_deck":
		in_deck_ui.show()
	elif type == "not_in_deck":
		not_in_deck_ui.show()
	else:
		pass

func _on_mouse_exited():
	in_deck_ui.hide()
	not_in_deck_ui.hide()

func _on_remove_button_pressed():
	if card_id:
		remove_from_deck.emit(card_id)

func _on_add_button_pressed():
	if card_id:
		add_to_deck.emit(card_id)
