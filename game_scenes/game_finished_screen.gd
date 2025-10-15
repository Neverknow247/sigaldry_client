extends Control

var scene_name = "game_finished"

var stats = Stats

@onready var background_color = $background_color

const COLOR_PROFILE_SQUARE_LARGE = preload("res://items/color_profile_square_large.tscn")

@onready var result_label = $center_container/v_box_container/result_label
@onready var winner_card = $center_container/v_box_container/h_box_container/winner_card
@onready var loser_card = $center_container/v_box_container/h_box_container/loser_card

func _ready():
	background_color.color = stats.background_color

func quit_game(payload):
	show()
	result_label.text = "%s defeated %s!" % [payload["winner_name"], payload["loser_name"]]
	$winner_card.add_details(payload["winner"],true)
	$loser_card.add_details(payload["loser"],true)
	#setup_card(winner_card, payload["winner"], payload["winner_name"])
	#setup_card(loser_card, payload["loser"], payload["loser_name"])

func setup_card(card,data,_name):
	#print("*********")
	card["card_name"].text = _name
	var card_effect_text = ""
	#for key in data:
		#print(key)
	#print("*********")
	for ability in data["abilities"]:
		#print(ability)
		if ability == "health":
			var card_hp = data["abilities"][ability]["value"]
			card["card_health"].text = str(int(card_hp)) if card_hp > 0 else ""
		elif ability == "attack":
			card["card_attack"].text = str(int(data["abilities"][ability]["value"]))
		elif ability == "actions":
			pass
		elif ability == "efficient":
			pass
		elif data["abilities"][ability]["value"] > 0:
			card_effect_text += data["abilities"][ability]["display_name"].capitalize() + "-" \
			+ str(int(data["abilities"][ability]["value"])) + "  "
		card["card_effects"].text = card_effect_text
		card["card_price"].text = str(int(data["cost"]))
	for _child in card["card_color_profile"].get_children():
		card["card_color_profile"].remove_child(_child)
		_child.queue_free()
	for color in data["color_profile"]:
		if color["magnitude"] > 0:
			var new_color = COLOR_PROFILE_SQUARE_LARGE.instantiate()
			card["card_color_profile"].add_child(new_color)
			new_color.color_square.color = Color(color["background_color"])
			new_color.color_magnitude.text = str(int(color["magnitude"]))

func _on_main_menu_button_pressed():
	hide()

func show_rewards(payload):
	print(payload)
