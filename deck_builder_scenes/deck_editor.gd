extends Control

var scene_name = "deck_editor"

signal deck_selected(id)
signal close_deck_editor
signal add_card_to_deck(id)
signal add_avatar_to_deck(id)
signal remove_card_from_deck(id)
signal change_deck_name(deck_name)
signal delete_deck
signal create_new_deck(deck_name)

const card_preview = preload("res://items/card_preview.tscn")

@onready var deck_select = $deck_select
@onready var deck_information = $deck_information
@onready var deck_name = $deck_information/deck_name
@onready var deck_label = $deck_information/deck_label
@onready var cards_in_deck_box = $CenterContainer/HBoxContainer/cards_in_deck/cards_in_deck_box
@onready var cards_not_in_deck_box = $CenterContainer/HBoxContainer/cards_not_in_deck/cards_not_in_deck_box
@onready var new_deck_screen = $new_deck_screen
@onready var new_deck_name = $new_deck_screen/CenterContainer/HBoxContainer/new_deck_name

func _on_back_button_pressed():
	close_deck_editor.emit()

func update_cards_in_deck(payload):
	#print("print cards in deck")
	clear_cards(cards_in_deck_box)
	if payload:
		add_cards(cards_in_deck_box,payload,"in_deck")

func update_cards_not_in_deck(payload):
	#print("print cards not in deck")
	clear_cards(cards_not_in_deck_box)
	if payload:
		add_cards(cards_not_in_deck_box,payload,"not_in_deck")

func clear_cards(parent):
	for n in parent.get_children():
		parent.remove_child(n)
		n.queue_free()

func add_cards(parent,payload,type):
	var card_number = 0
	var row_node
	for card in payload["cards"]:
		if card_number == 0:
			row_node = HBoxContainer.new()
			parent.add_child(row_node)
			row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			row_node.add_theme_constant_override("separation",10)
		var new_card = card_preview.instantiate()
		row_node.add_child(new_card)
		if type == "in_deck":
			if int(card["id"]) == int(payload["avatar_id"]):
				new_card.activate_avatar()
		new_card["card_name"].text = card["name"]
		new_card["card_type"].text = card["subtype"].capitalize()
		new_card["card_id"] = card["id"]
		if type == "not_in_deck" and card["subtype"] == "unit":
			new_card["type"] = "unit_not_in_deck"
		else:
			new_card["type"] = type
		new_card.connect("add_avatar_to_deck",avatar_to_deck)
		new_card.connect("add_to_deck",add_to_deck)
		new_card.connect("remove_from_deck",remove_from_deck)
		var card_effect_text = ""
		var discount = 0
		for ability in card["abilities"]:
			if card["abilities"][ability]["name"] == "health":
				var card_hp = card["abilities"][ability]["value"]
				new_card["card_health"].text = str(card_hp) if card_hp > 0 else ""
			elif card["abilities"][ability]["name"] == "attack":
				new_card["card_attack"].text = str(card["abilities"][ability]["value"])
			elif card["abilities"][ability]["name"] == "actions":
				pass
			elif card["abilities"][ability]["name"] == "efficient":
				discount = card["abilities"][ability]["value"]
			elif card["abilities"][ability]["value"] > 0:
				card_effect_text += card["abilities"][ability]["name"].capitalize() + " " \
				+ str(card["abilities"][ability]["value"]) + "  " 
		new_card["card_effects"].text = card_effect_text
		new_card["card_price"].text = str(card["cost"]-discount)
		card_number+=1
		if card_number == 3:
			card_number = 0

func add_to_deck(card_id):
	add_card_to_deck.emit(card_id)

func avatar_to_deck(card_id):
	add_avatar_to_deck.emit(card_id)

func remove_from_deck(card_id):
	remove_card_from_deck.emit(card_id)

func start_deck_editor(payload):
	print("starting deck editor")
	deck_information.hide()
	if payload:
		pass

func update_decks(payload):
	deck_select.clear()
	deck_select.add_item("Select A Deck", -1)
	deck_select.add_separator()
	for item in payload["decks"]:
		deck_select.add_item(item["name"],item["id"])
		if item["active"] == true:
			deck_information.show()
			deck_name.text = item["name"]

func _on_deck_select_item_selected(index):
	deck_selected.emit(deck_select.get_selected_id())
	deck_information.show()
	deck_name.text = deck_select.get_item_text(index)
	#deck_label.text = deck_select.get_item_text(index)
	#print("Selected id: ", deck_select.get_selected_id())

func _on_deck_name_text_changed(new_text):
	if deck_name.text != "":
		change_deck_name.emit(deck_name.text)

func _on_delete_deck_button_pressed():
	delete_deck.emit()
	deck_information.hide()

func _on_new_deck_button_pressed():
	new_deck_name.text = ""
	new_deck_screen.show()

func _on_create_deck_button_pressed():
	if new_deck_name.text != "":
		create_new_deck.emit(new_deck_name.text)
		new_deck_screen.hide()

func _on_cancel_create_deck_button_pressed():
	new_deck_screen.hide()
