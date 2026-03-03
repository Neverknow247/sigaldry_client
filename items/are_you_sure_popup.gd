extends Popup

@onready var are_you_sure_label: Label = $color_rect/center_container/v_box_container/are_you_sure_label
@onready var yes_button: Button = $color_rect/center_container/v_box_container/h_box_container/yes_button
@onready var no_button: Button = $color_rect/center_container/v_box_container/h_box_container/no_button

signal yes()
signal no()

func _on_yes_button_pressed() -> void:
	yes.emit()
	queue_free()

func _on_no_button_pressed() -> void:
	no.emit()
	queue_free()
