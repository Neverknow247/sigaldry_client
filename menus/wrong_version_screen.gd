extends Control

var scene_name = "wrong_version"

var stats = Stats

@onready var color_background: ColorRect = $color_background

func _ready() -> void:
	color_background.color = stats.background_color

func _on_exit_button_pressed() -> void:
	get_tree().quit()
