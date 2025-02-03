extends Control

var scene_name = "login"

@onready var username = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/username
@onready var password = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/password

signal login(username,password)
signal change_screen_to_register

# this login button reads from input fields -- * no error handling
func _on_sign_in_button_pressed():
	login.emit(username.text,password.text)

func _on_register_new_user_button_pressed():
	change_screen_to_register.emit()

func _on_quit_button_pressed():
	get_tree().quit()

signal auto_login
func _on_auto_login_button_pressed():
	auto_login.emit()
