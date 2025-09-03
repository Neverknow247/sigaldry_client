extends Control

var scene_name = "card_view"

var stats = Stats

const CARD_SCENE = preload("res://items/card.tscn")

var binder_width = 5

@onready var background_color = $background_color

@onready var scroll_container = $ScrollContainer
@onready var v_box_container = $ScrollContainer/VBoxContainer

signal exit_menu

func _ready():
	background_color.color = stats.background_color

func add_cards(payload):
	for n in v_box_container.get_children():
		v_box_container.remove_child(n)
		n.queue_free()
	var card_number = 0
	var row_node
	var first_card = true
	for card in payload["cards"]:
		#print("Card: ",card["image"])
		if first_card:
			first_card = false
		if card_number == 0:
			row_node = HBoxContainer.new()
			v_box_container.add_child(row_node)
			row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			row_node.add_theme_constant_override("separation", 25)
		var new_card = CARD_SCENE.instantiate()
		row_node.add_child(new_card)
		new_card.define_scale(4)
		new_card.add_details(card)
		card_number+=1
		if card_number == binder_width:
			new_card.last_card  = true
			card_number = 0

#func add_cards(payload):
		#var new_card = card_preview.instantiate()
		#row_node.add_child(new_card)
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
		#
		#card_number+=1
		#if card_number == binder_width:
			#card_number = 0
		#
		#
		#
		#
		##for deck in payload["decks"]:
		##var new_deck_button = deck_button.instantiate()
		##new_deck_button["deck_id"] = deck["id"]
		##new_deck_button.text = deck["name"]
		##new_deck_button.deck_selected.connect(deck_selected)
		##$deck_select/CenterContainer/all_decks.add_child(new_deck_button)

func _on_back_button_pressed():
	exit_menu.emit()
