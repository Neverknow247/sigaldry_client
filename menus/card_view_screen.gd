extends Control

var scene_name = "card_view"

const card_preview = preload("res://items/card_preview.tscn")

var binder_width = 4

@onready var scroll_container = $ScrollContainer
@onready var v_box_container = $ScrollContainer/VBoxContainer

signal exit_menu

func add_cards(payload):
	#print(payload)
	for n in v_box_container.get_children():
		v_box_container.remove_child(n)
		n.queue_free()
	var card_number = 0
	var row_node
	for card in payload["cards"]:
		if card_number == 0:
			row_node = HBoxContainer.new()
			v_box_container.add_child(row_node)
			row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			row_node.add_theme_constant_override("separation",25)
		var new_card = card_preview.instantiate()
		row_node.add_child(new_card)
		new_card["card_name"].text = card["card"]["name"]
		var card_effect_text = ""
		var discount = 0
		print(card)
		if card["card"]["keywords"]:
			for ability in card["card"]["keywords"]:
				print(ability)
				if ability["name"] == "health":
					var card_hp = ability["value"]
					new_card["card_health"].text = str(card_hp) if card_hp > 0 else ""
				elif ability["name"] == "attack":
					new_card["card_attack"].text = str(ability["value"])
				elif ability["name"] == "actions":
					pass
				elif ability["name"] == "efficient":
					discount = ability["value"]
				elif ability["value"] > 0:
					card_effect_text += ability["name"].capitalize() + " " \
					+ str(ability["value"]) + "  " 
		new_card["card_effects"].text = card_effect_text
		new_card["card_price"].text = str(card["card"]["cost"]-discount)
		
		card_number+=1
		if card_number == binder_width:
			card_number = 0
		
		
		
		
		#for deck in payload["decks"]:
		#var new_deck_button = deck_button.instantiate()
		#new_deck_button["deck_id"] = deck["id"]
		#new_deck_button.text = deck["name"]
		#new_deck_button.deck_selected.connect(deck_selected)
		#$deck_select/CenterContainer/all_decks.add_child(new_deck_button)

func _on_back_button_pressed():
	exit_menu.emit()
