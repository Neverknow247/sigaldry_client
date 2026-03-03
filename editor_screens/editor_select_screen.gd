extends Control

var scene_name = "editor_select"

var stats = Stats
var KEYWORD_GLOSS = KeyWordGlossary

@onready var background_color: ColorRect = $background/background_color

signal card_editor
signal card_fusion
signal deck_editor

func _ready():
	background_color.color = stats.background_color

func _on_card_editor_button_pressed() -> void:
	card_editor.emit()

func _on_card_fusion_button_pressed() -> void:
	card_fusion.emit()

func _on_deck_editor_button_pressed() -> void:
	deck_editor.emit()
