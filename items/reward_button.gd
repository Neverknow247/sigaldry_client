extends HBoxContainer

@onready var button: Button = $button
@onready var spin_box: SpinBox = $spin_box

var reward_id

signal selected_reward(_reward_id, _amount)

func _on_button_pressed() -> void:
	button.disabled = true
	selected_reward.emit(reward_id, spin_box.value)
