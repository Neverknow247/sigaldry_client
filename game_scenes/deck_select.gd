extends HBoxContainer

@onready var button = $Button
@onready var label = $Label

var deck_id : int
var deck_name : String

signal select_deck(id)

func _on_button_pressed():
	select_deck.emit(deck_id)
