extends Control

const AVATAR_TEXTURE = preload("res://assets/art/card_template_avatar.png")
const COLOR_PROFILE_SQUARE = preload("res://items/color_profile_square_large.tscn")

signal remove_from_deck(id)
signal add_avatar_to_deck(id)
signal add_to_deck(id)
signal select_card(id)
signal add_avatar_to_new_deck(id)
signal get_info(data)
signal compare_card(id)

@onready var card_texture = $card_texture
@onready var card_image = $card_image
@onready var card_color_profile = $card_color_profile
@onready var card_cost = $labels/card_cost
@onready var card_name = $labels/card_name
@onready var card_effects = $labels/card_effects
@onready var card_attack = $labels/card_attack
@onready var card_health = $labels/card_health
@onready var card_type = $labels/card_type
@onready var card_author = $labels/card_author

var type = ""
var source_type = ""
var card_id = 0

func activate_avatar():
	card_texture = AVATAR_TEXTURE

func add_details(card_details):
	print(card_details)

#func set_color_profile(colors):
	#pass
	#
	#for card in payload["cards"]:
		#write_card(card)
#
#func write_card(card):
	#card_name.text = card["card"]["name"]
#
		#new_card["card_name"].text = card["card"]["name"]
		#new_card["card_type"].text = card["card"]["subtype"].capitalize()
		#var card_effect_text = ""
		#var discount = 0
		##print(card)
		#if card["card"]["keywords"]:
			#for ability in card["card"]["keywords"]:
				##print(ability)
				#if ability["name"] == "health":
					#var card_hp = ability["value"]
					#new_card["card_health"].text = str(int(card_hp)) if card_hp > 0 else ""
				#elif ability["name"] == "attack":
					#new_card["card_attack"].text = str(int(ability["value"]))
				#elif ability["name"] == "actions":
					#pass
				#elif ability["name"] == "efficient":
					#discount = ability["value"]
				#elif ability["value"] > 0:
					#card_effect_text += ability["name"].capitalize() + "-" \
					#+ str(int(ability["value"])) + "  " 
					##+ str(int(ability["value"])) + "  " 
		#new_card["card_effects"].text = card_effect_text
		#new_card["card_price"].text = str(int(card["card"]["cost"]-discount))
		#
		#for _child in new_card.card_color_profile.get_children():
			#new_card.card_color_profile.remove_child(_child)
			#_child.queue_free()
		#for color in card["card"]["color_profile"]:
			#var new_color = COLOR_PROFILE_SQUARE_LARGE.instantiate()
			#new_card.card_color_profile.add_child(new_color)
			#new_color.color_square.color = Color(stats.COLOR_KEY[color["id"]])
			#new_color.color_magnitude.text = str(int(color["magnitude"]))
