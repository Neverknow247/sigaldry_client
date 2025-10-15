extends Control

var scene_name = "register"

var stats = Stats

@onready var background_color = $background_color

@onready var username = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/username
@onready var screen_name = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/screen_name
@onready var email: LineEdit = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/email
@onready var password = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/password

signal register(username,screen_name,password)
signal change_screen_to_login

func _ready():
	background_color.color = stats.background_color

func _on_register_button_pressed():
	if username.text == "" or screen_name.text == "" or email.text == "" or password.text == "":
		pass
	else:
		register.emit(username.text,screen_name.text,email.text,password.text)

func _on_return_to_login_button_pressed():
	change_screen_to_login.emit()
	reset_screen()

func reset_screen():
	username.text = ""
	screen_name.text = ""
	email.text = ""
	password.text = ""

func _on_quit_button_pressed():
	get_tree().quit()
