extends Control

@onready var fade = $fade
@onready var animation_player = $animation_player

func _ready():
	show()
	fade_in()

func fade_in():
	animation_player.play("fade_in")

func fade_out():
	animation_player.play("fade_out")
