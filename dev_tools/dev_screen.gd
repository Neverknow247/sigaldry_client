extends Control

var stats = Stats

signal auto_login(data)
signal add_templates
signal add_components
signal get_reward
signal open_common_reward
signal open_uncommon_reward
signal get_glossary
signal edit_card(_id)

var dev_tools_open = false:
	set(value):
		dev_tools_open = value
		visible = value

func _ready():
	if stats.dev_mode:
		dev_tools_open = true

func _input(event):
	if Input.is_action_just_pressed("show_dev_tool") and stats.dev_mode:
		dev_tools_open = !dev_tools_open

func _on_neverknow_login_button_pressed():
	auto_login.emit({'username':"neverknow247",'password':"ZcX%0SPav!se9d*S"})

func _on_comp_login_button_pressed():
	auto_login.emit({'username':"comp9001",'password':"43Kc@7HHtp#SAvFw"})

func _on_add_templates_button_pressed():
	add_templates.emit()

func _on_add_components_button_pressed():
	add_components.emit()

func _on_get_reward_button_pressed():
	get_reward.emit()

func _on_open_common_button_pressed() -> void:
	open_common_reward.emit()

func _on_open_uncommon_button_pressed() -> void:
	open_uncommon_reward.emit()

func _on_hide_button_pressed():
	dev_tools_open = !dev_tools_open

func _on_get_glossary_button_pressed() -> void:
	get_glossary.emit()

func _on_edit_card_image_button_pressed() -> void:
	if int($h_box_container/v_box_container2/h_box_container/edit_card_line.text):
		edit_card.emit(int($h_box_container/v_box_container2/h_box_container/edit_card_line.text))
