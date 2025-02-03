extends Control

var scene_name = "waiting"

@onready var label = $Label

var cancel_status = ""

signal cancel_validation
signal cancel_game

func _on_cancel_button_pressed():
	if cancel_status == "cancel-waiting-for-validation":
		cancel_validation.emit()
	elif cancel_status == "cancel-waiting-for-game":
		cancel_game.emit()
	else:
		return

func waiting(payload):
	if payload:
		cancel_status = payload["oncancel"]
		label.text = payload["title"]
		
