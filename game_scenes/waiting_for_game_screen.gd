extends Control

var scene_name = "waiting"

var stats = Stats

@onready var background_color = $background_color

@onready var label = $Label

var cancel_status = ""

signal cancel_validation
signal cancel_game

func _ready():
	background_color.color = stats.background_color

func _on_cancel_button_pressed():
	if cancel_status == "cancel-waiting-for-validation":
		cancel_validation.emit()
	elif cancel_status == "cancel-waiting-for-game":
		cancel_game.emit()
	else:
		return

func waiting(payload):
	if payload.has("oncancel"):cancel_status = payload["oncancel"]
	if payload.has("title"):label.text = payload["title"]
		
