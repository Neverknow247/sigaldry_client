extends Control

const AVATAR_TEXTURE = preload("res://assets/art/card_template_avatar.png")
const COLOR_PROFILE_SQUARE = preload("res://items/magnitude_square.tscn")

var stats = Stats

signal remove_from_deck(id)
signal add_avatar_to_deck(id)
signal add_to_deck(id)
signal select_card(id)
signal add_avatar_to_new_deck(id)
signal get_info(data)
signal compare_card(id)

@onready var content = $content
@onready var card_texture = $content/card_texture
@onready var card_image = $content/card_image
@onready var card_color_profile = $content/card_color_profile
@onready var card_cost = $content/labels/card_cost
@onready var card_name = $content/labels/card_name
@onready var card_effects = $content/labels/card_effects
@onready var card_attack = $content/labels/card_attack
@onready var card_health = $content/labels/card_health
@onready var card_type = $content/labels/card_type
@onready var card_author = $content/labels/card_author
@onready var card_actions = $content/labels/card_actions

var type = ""
var source_type = ""
var card_id = 0

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

func add_details(card_details):
	print(card_details)
	card_id = card_details["id"]
	set_color_profile(card_details["card_json"]["color_profile"])
	card_cost.text = str(int(card_details["card_json"]["cost"]))
	card_name.text = card_details["card_json"]["name"]
	set_card_effects(card_details["card_json"]["keywords"])
	card_type.text = card_details["card_json"]["subtype"].capitalize()
	card_author.text = card_details["unique_author"]

func set_card_effects(keywords):
	var card_effect_text = ""
	for k in keywords:
		match k["name"]:
			"attack":
				card_attack.text = str(int(k["value"]))
			"health":
				card_health.text = str(int(k["value"])) if k["value"] > 0 else ""
			"actions":
				card_actions.size.x = 36* (k["value"])
			"efficient":
				pass
			_:
				pass
				card_effect_text += k["name"].capitalize() + "-" \
				+ str(int(k["value"])) + "  "
	card_effects.text = card_effect_text

func set_color_profile(colors):
	for _child in card_color_profile.get_children():
		card_color_profile.remove_child(_child)
		_child.queue_free()
	for color in colors:
		var new_color = COLOR_PROFILE_SQUARE.instantiate()
		card_color_profile.add_child(new_color)
		new_color.color_square.color = Color(stats.COLOR_KEY[color["id"]])
		new_color.color_magnitude.text = str(int(color["magnitude"]))

func add_builder_details(card_details):
	print("details: ",card_details)
	card_id = card_details["id"]
	set_color_profile(card_details["card"]["color_profile"])
	card_cost.text = str(int(card_details["card"]["cost"]))
	card_name.text = card_details["card"]["name"]
	set_card_effects(card_details["card"]["keywords"])
	card_type.text = card_details["card"]["subtype"].capitalize()
	card_author.text = card_details["card"]["unique_author"]
