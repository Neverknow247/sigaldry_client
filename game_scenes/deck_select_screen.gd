extends Control

var scene_name = "deck_select"

var stats = Stats

const deck_select = preload("res://game_scenes/deck_select.tscn")

@onready var background_color = $background_color

@onready var v_box_container = $ScrollContainer/VBoxContainer

signal select_deck(id)
signal cancel_deck_select

func _ready():
	background_color.color = stats.background_color

func add_decks(payload):
	print(payload)
	for n in v_box_container.get_children():
		v_box_container.remove_child(n)
		n.queue_free()
	for deck in payload["decks"]:
		var new_deck = deck_select.instantiate()
		v_box_container.add_child(new_deck)
		new_deck.deck_id = deck["id"]
		new_deck.deck_name = deck["name"]
		new_deck.label.text = deck["name"]
		new_deck.select_deck.connect(_on_select_deck)

func _on_select_deck(id):
	#print(id)
	select_deck.emit(id)

func _on_cancel_button_pressed():
	cancel_deck_select.emit()
