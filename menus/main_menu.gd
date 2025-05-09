extends Control

var scene_name = "menu"

var stats = Stats

@onready var background_color = $background_color
@onready var game_finished_screen = $game_finished_screen

signal logout
signal search_for_pvp_game
signal search_for_pve_game
signal view_all_cards
signal start_card_builder
signal start_deck_editor

func _ready():
	background_color.color = stats.background_color

func _on_logout_button_pressed():
	stats["save_data"]["remember_me"]["username"] = ""
	stats["save_data"]["remember_me"]["password"] = ""
	SaveAndLoad.save_all()
	logout.emit()

func _on_quit_button_pressed():
	logout.emit()
	get_tree().quit()

func _on_search_for_a_pvp_game_button_pressed():
	search_for_pvp_game.emit()

func _on_search_for_a_pve_game_pressed():
	search_for_pve_game.emit()

func _on_view_cards_button_pressed():
	view_all_cards.emit()

func _on_card_builder_button_pressed():
	start_card_builder.emit()

func _on_deck_editor_button_pressed():
	start_deck_editor.emit()

func quit_game(payload):
	game_finished_screen.quit_game(payload)
