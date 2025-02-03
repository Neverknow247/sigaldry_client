extends Control

var scene_name = "register"

@onready var username = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/username
@onready var screen_name = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/screen_name
@onready var password = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/password

signal register(username,screen_name,password)
signal change_screen_to_login

func _on_register_button_pressed():
	if username.text == "" or screen_name.text == "" or password.text == "":
		pass
	else:
		register.emit(username.text,screen_name.text,password.text)

func _on_return_to_login_button_pressed():
	change_screen_to_login.emit()

func _on_quit_button_pressed():
	get_tree().quit()
