extends HBoxContainer

signal component_selected(_id)

var component_id : int

func _on_button_pressed():
	component_selected.emit(component_id)
