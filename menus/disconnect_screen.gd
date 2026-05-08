extends Control

var scene_name = "disconnect_screen"

var stats = Stats
var utils = Utils

@onready var background_color: ColorRect = $background_color

func _ready() -> void:
	background_color.color = stats.background_color
