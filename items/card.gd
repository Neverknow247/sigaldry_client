extends Control

const AVATAR_TEXTURE = preload("res://assets/art/card_template_avatar.png")
const COLOR_PROFILE_SQUARE = preload("res://items/magnitude_square.tscn")

var stats = Stats
var KEYWORD_GLOSS = KeyWordGlossary

signal remove_from_deck(id)
signal add_avatar_to_deck(id)
signal add_to_deck(id)
signal select_card(id)
signal game_select_card()
signal mouse_focus(_pos,_focus,card_id)
signal add_avatar_to_new_deck(id)
signal get_info(data)
signal compare_card(id)

@onready var content = $content
@onready var card_texture = $content/card_texture
@onready var card_image = $content/card_image
@onready var card_color_profile = $content/card_image/color_banner/card_color_profile
@onready var color_banner_animation_player: AnimationPlayer = $content/card_image/color_banner/color_banner_animation_player
@onready var card_cost = $content/labels/card_cost
@onready var card_name = $content/labels/card_name
@onready var card_effects = $content/labels/card_effects
@onready var card_attack = $content/labels/card_attack
@onready var card_health = $content/labels/card_health
@onready var card_type: Label = $content/card_details/card_details_background/content/card_type
@onready var card_author: Label = $content/card_details/card_details_background/content/card_author
@onready var card_actions = $content/labels/card_actions
@onready var card_rich_effects = $content/card_rich_effects
@onready var card_details: Control = $content/card_details
@onready var card_details_box: VBoxContainer = $content/card_details/card_details_background/content/scroll_container/card_details_box
@onready var card_details_timer: Timer = $content/card_details/card_details_timer
@onready var card_details_animation_player: AnimationPlayer = $content/card_details/card_details_animation_player

var type = ""
var source_type = ""
var card_id = 0

var card_button_type = null

@export var last_card  = false
var card_details_open=  false:
	get:
		return card_details_open
	set(value):
		card_details_open = value
		match value:
			true:
				if !last_card: card_details_animation_player.play("open_card_details_right")
				else: card_details_animation_player.play("open_card_details_left")
			false:
				if !last_card: card_details_animation_player.play("close_card_details_right")
				else: card_details_animation_player.play("close_card_details_left")

var color_banner_open =  false:
	get:
		return color_banner_open
	set(value):
		color_banner_open = value
		match value:
			true:
				color_banner_animation_player.play("open_color_banner")
			false:
				color_banner_animation_player.play("close_color_banner")

func define_scale(size):
	match size:
		1:
			custom_minimum_size = Vector2(81.6,112)
			content.scale = Vector2(.1,.1)
		2:
			custom_minimum_size = Vector2(163.2,224)
			content.scale = Vector2(.2,.2)
		3:
			custom_minimum_size = Vector2(244.8,336)
			content.scale = Vector2(.3,.3)
		4:
			custom_minimum_size = Vector2(326.4,448)
			content.scale = Vector2(.4,.4)
		5:
			custom_minimum_size = Vector2(408,560)
			content.scale = Vector2(.5,.5)

func activate_avatar():
	card_texture = AVATAR_TEXTURE

func add_details(_card_details):
	print("card_details: ",_card_details)
	card_id = _card_details["id"]
	set_color_profile(_card_details["color_profile"])
	card_cost.text = str(int(_card_details["cost"]))
	if _card_details["name"]:
		card_name.text = _card_details["name"]
	var image_path = "res://assets/temp_image_folder/%s" %[_card_details["image"]]
	if FileAccess.file_exists(image_path):
		card_image.texture = load(image_path)
	else:
		match _card_details["subtype"]:
			"unit":
				card_image.texture = load("res://assets/missing-images/none-unit.png")
			"spell":
				card_image.texture = load("res://assets/missing-images/none-spell.png")
			"trap":
				card_image.texture = load("res://assets/missing-images/none-trap.png")
			"potion":
				card_image.texture = load("res://assets/missing-images/none-potion.png")
	set_card_effects(_card_details["abilities"])
	card_type.text = _card_details["subtype"].capitalize()
	card_author.text = _card_details["meta"]["designer"]["user_name"]

#func add_builder_details(_card_details):
	#print("details: ",card_details)
	#card_id = _card_details["id"]
	#set_color_profile(_card_details["card"]["color_profile"])
	#card_cost.text = str(int(_card_details["card"]["cost"]))
	#card_name.text = _card_details["card"]["name"] if _card_details["card"]["name"] != null else ""
	#set_card_effects(_card_details["card"]["abilities"])
	#card_type.text = _card_details["card"]["subtype"].capitalize()
	#card_author.text = _card_details["card"]["meta"]["designer"]["user_name"]

func set_card_effects(abilities):
	var card_effect_text = ""
	for ability_key in abilities:
		var ability = abilities[ability_key]
		match ability["name"]:
			"attack":
				card_attack.text = str(int(ability["value"]))
			"health":
				card_health.text = str(int(ability["value"])) if ability["value"] > 0 else ""
			"actions":
				card_actions.size.x = 36* (ability["value"])
			"efficient":
				pass
			_:
				pass
				#card_effect_text += "[url="+k["name"]+"]"+k["name"].capitalize() +"[/url]"+ ":" \
				#+ str(int(k["value"])) + "  "
				card_effect_text += ability["name"].capitalize() + ":" \
				+ str(int(ability["value"])) + "  "
				#var effect_label = Label.new()
				var effect_label = preload("res://items/card_info_label.tscn").instantiate()
				card_details_box.add_child(effect_label)
				effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				effect_label.text = "[b]"+ability["name"].capitalize()+"[/b] : " 
				effect_label.text += KEYWORD_GLOSS.glossary[ability["name"]]["description"]
				
	card_rich_effects.text = card_effect_text

func set_color_profile(colors):
	for _child in card_color_profile.get_children():
		card_color_profile.remove_child(_child)
		_child.queue_free()
	for color_key in colors:
		var color =  colors[color_key]
		var new_color = COLOR_PROFILE_SQUARE.instantiate()
		card_color_profile.add_child(new_color)
		new_color.color_square.color = Color(stats.COLOR_KEY[color["key"]])
		new_color.color_magnitude.text = str(int(color["magnitude"]))

func set_avatar():
	print("Add Avatar Image")


func _on_card_button_pressed():
	match card_button_type:
		"deck_editor_in_deck":
			remove_from_deck.emit(card_id)
		"deck_editor_not_in_deck":
			add_to_deck.emit(card_id)
		"game_card_select":
			select_card.emit(card_id)
		"game_type":
			game_select_card.emit()
		"builder_compare_select":
			compare_card.emit(card_id)
		"select":
			select_card.emit(card_id)
		_:
			print(card_button_type)
			return

#func _on_card_button_mouse_entered() -> void:
	#return
	#card_details_timer.start(card_details_timer.wait_time)
#
#func _on_card_button_mouse_exited() -> void:
	#return
	#card_details_timer.stop()
	#card_details.hide()

func _on_card_details_timer_timeout() -> void:
	card_details.show()

func _on_color_banner_button_pressed() -> void:
	if !color_banner_animation_player.is_playing():
		color_banner_open = !color_banner_open

func _on_card_details_button_pressed() -> void:
	if !card_details_animation_player.is_playing():
		card_details_open = !card_details_open

func _on_card_button_mouse_entered() -> void:
	if card_button_type == "game_type":
		mouse_focus.emit(global_position,true,card_id,source_type)

func _on_card_button_mouse_exited() -> void:
	if card_button_type == "game_type":
		mouse_focus.emit(global_position,true,card_id,source_type)

func _on_card_button_get_info() -> void:
	if card_button_type == "game_type":
		get_info.emit({"type":"card","id":card_id})
