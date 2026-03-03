extends Control

var scene_name = "login"

var stats = Stats
var utils = Utils

@onready var background: TextureRect = $background
@onready var background_color = $background_color

@onready var username = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/username
@onready var password = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/password
@onready var remember_me_checkbox = $remember_me/remember_me_checkbox

@onready var line_edit: LineEdit = $custom_ip_container/line_edit

signal login(username,password)
signal change_screen_to_register
signal change_ip(_new_ip)

func _ready():
	background.texture = utils.random_background()
	background_color.color = stats.background_color
	check_remember_me()

func check_remember_me():
	if stats["save_data"]["remember_me"]["username"] != "":
		username.text = stats["save_data"]["remember_me"]["username"]
		password.text = stats["save_data"]["remember_me"]["password"]
		remember_me_checkbox.button_pressed = true
		

# this login button reads from input fields -- * no error handling
func _on_sign_in_button_pressed():
	if remember_me_checkbox.button_pressed:
		stats["save_data"]["remember_me"]["username"] = username.text
		stats["save_data"]["remember_me"]["password"] = password.text
	else:
		stats["save_data"]["remember_me"]["username"] = ""
		stats["save_data"]["remember_me"]["password"] = ""
	SaveAndLoad.save_all()
	login.emit(username.text,password.text)

func _on_register_new_user_button_pressed():
	change_screen_to_register.emit()
	reset_screen()

func reset_screen():
	username.text = ""
	password.text = ""
	

func _on_quit_button_pressed():
	get_tree().quit()


func _on_connect_button_pressed() -> void:
	change_ip.emit(line_edit.text)
