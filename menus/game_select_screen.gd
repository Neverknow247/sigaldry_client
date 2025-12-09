extends Control
var scene_name = "game_select"

var stats = Stats

const REWARD_BUTTON = preload("res://items/reward_button.tscn")
const REWARD_LABEL = preload("res://items/reward_label.tscn")

@onready var color_background: ColorRect = $color_background

signal close_game_select

func _ready() -> void:
	color_background.color = stats.background_color

func _on_back_button_pressed() -> void:
	close_game_select.emit()

func set_up_pvp(payload):
	pass

func set_up_pve(payload):
	for decks in payload["pve_opponent_decks"]:
		print(decks)
	#print(payload)
