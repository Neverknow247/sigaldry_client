extends Button

signal get_info

func _gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_mask == MOUSE_BUTTON_RIGHT:
				print("get info")
				get_info.emit()
