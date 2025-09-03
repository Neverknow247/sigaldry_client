extends Control

var scene_name = "deck_editor"

var stats = Stats

signal deck_selected(id)
signal close_deck_editor
signal add_card_to_deck(id)
signal add_avatar_to_deck(id)
signal remove_card_from_deck(id)
signal change_deck_name(deck_name)
signal delete_deck
signal create_new_deck(deck_name)
signal show_units_only

const CARD_SCENE = preload("res://items/card.tscn")
const COLOR_PROFILE_SQUARE_LARGE = preload("res://items/color_profile_square_large.tscn")

@onready var color_background = $color_background

@onready var deck_select = $deck_select
@onready var deck_information = $deck_information
@onready var deck_name = $deck_information/deck_name
@onready var deck_label = $deck_information/deck_label
@onready var cards_in_deck_box = $CenterContainer/HBoxContainer/cards_in_deck/cards_in_deck_box
@onready var cards_not_in_deck_box = $CenterContainer/HBoxContainer/cards_not_in_deck/cards_not_in_deck_box
@onready var cards_units_only_box = $new_deck_screen/CenterContainer2/HBoxContainer/cards_units_only/cards_units_only_box
@onready var new_deck_screen = $new_deck_screen
@onready var new_deck_name = $new_deck_screen/CenterContainer/HBoxContainer/new_deck_name

@onready var na_label = $new_deck_screen/CenterContainer2/HBoxContainer/VBoxContainer/na_label
@onready var avatar_preview = $new_deck_screen/CenterContainer2/HBoxContainer/VBoxContainer/CenterContainer/Control/avatar_preview
#@onready var avatar_name = $new_deck_screen/CenterContainer2/HBoxContainer/VBoxContainer/CenterContainer/Control/avatar_preview/card_name
#@onready var avatar_effects = $new_deck_screen/CenterContainer2/HBoxContainer/VBoxContainer/CenterContainer/Control/avatar_preview/card_effects
#@onready var avatar_type = $new_deck_screen/CenterContainer2/HBoxContainer/VBoxContainer/CenterContainer/Control/avatar_preview/card_type
#@onready var avatar_price = $new_deck_screen/CenterContainer2/HBoxContainer/VBoxContainer/CenterContainer/Control/avatar_preview/card_price
#@onready var avatar_attack = $new_deck_screen/CenterContainer2/HBoxContainer/VBoxContainer/CenterContainer/Control/avatar_preview/card_attack
#@onready var avatar_health = $new_deck_screen/CenterContainer2/HBoxContainer/VBoxContainer/CenterContainer/Control/avatar_preview/card_health

var selected_avatar_id = 0

func _ready():
	color_background.color = stats.background_color
	new_deck_screen.color = stats.background_color

func _on_back_button_pressed():
	avatar_preview.hide()
	na_label.show()
	close_deck_editor.emit()

func update_cards_in_deck(payload):
	print(payload)
	#print("print cards in deck")
	clear_cards(cards_in_deck_box)
	if payload:
		add_cards(cards_in_deck_box,payload,"deck_editor_in_deck")

func update_cards_not_in_deck(payload):
	print(payload)
	#print("print cards not in deck")
	clear_cards(cards_not_in_deck_box)
	if payload:
		add_cards(cards_not_in_deck_box,payload,"deck_editor_not_in_deck")

func update_cards_unit_only(payload):
	clear_cards(cards_units_only_box)
	if payload:
		add_unit_only_cards(cards_units_only_box,payload,"unit_only")


func clear_cards(parent):
	for n in parent.get_children():
		parent.remove_child(n)
		n.queue_free()

func add_cards(parent,payload,type):
	if !payload["cards"] :
		return
	#print("parent: ", parent, " | payload: ", payload, " | type: ", type)
	var card_number = 0
	var row_node
	for card in payload["cards"]:
		if card_number == 0:
			row_node = HBoxContainer.new()
			parent.add_child(row_node)
			row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			row_node.add_theme_constant_override("separation",10)
		var new_card = CARD_SCENE.instantiate()
		row_node.add_child(new_card)
		new_card.define_scale(3)
		new_card.add_details(card)
		
		#print("*******")
		#print(type)
		#print("########")
		#print(card)
		#print("*******")
		
		#if type == "not_in_deck" and card["card_json"]["subtype"] == "unit":
			#new_card["card_button_type"] = "deck_editor_not_in_deck"
		if type == "in_deck" and int(card["id"]) == int(payload["avatar_id"]):
			new_card["card_button_type"] = null
			new_card.set_avatar()
		else:
			new_card["card_button_type"] = type
		
		new_card.connect("add_avatar_to_deck",avatar_to_deck)
		new_card.connect("add_to_deck",add_to_deck)
		new_card.connect("remove_from_deck",remove_from_deck)
		card_number+=1
		if card_number == 3:
			card_number = 0

#func add_cards(parent,payload,type):
	#var card_number = 0
	#var row_node
	#for card in payload["cards"]:
		#if card_number == 0:
			#row_node = HBoxContainer.new()
			#parent.add_child(row_node)
			#row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			#row_node.add_theme_constant_override("separation",10)
		#var new_card = card_preview.instantiate()
		#row_node.add_child(new_card)
		#new_card["card_name"].text = card["name"]
		#new_card["card_type"].text = card["subtype"].capitalize()
		#new_card["card_id"] = card["id"]
		##if type == "not_in_deck" and card["subtype"] == "unit":
			##new_card["type"] = "unit_not_in_deck"
		#if type == "in_deck" and int(card["id"]) == int(payload["avatar_id"]):
			#new_card.activate_avatar()
			#
			#for _child in new_card.card_color_profile.get_children():
				#new_card.card_color_profile.remove_child(_child)
				#_child.queue_free()
			#for color in card["color_profile"]:
				#if color["magnitude"] > 0:
					#var new_color = COLOR_PROFILE_SQUARE_LARGE.instantiate()
					#new_card.card_color_profile.add_child(new_color)
					#print(color)
					#new_color.color_square.color = Color(stats.COLOR_KEY[color["id"]])
					#new_color.color_magnitude.text = str(int(color["magnitude"]))
			#
			#
			#
		#else:
			#new_card["type"] = type
		#new_card.connect("add_avatar_to_deck",avatar_to_deck)
		#new_card.connect("add_to_deck",add_to_deck)
		#new_card.connect("remove_from_deck",remove_from_deck)
		#var card_effect_text = ""
		#@warning_ignore("unused_variable")
		#var discount = 0
		#for ability in card["abilities"]:
			#if card["abilities"][ability]["name"] == "health":
				#var card_hp = card["abilities"][ability]["value"]
				#new_card["card_health"].text = str(int(card_hp)) if card_hp > 0 else ""
			#elif card["abilities"][ability]["name"] == "attack":
				#new_card["card_attack"].text = str(int(card["abilities"][ability]["value"]))
			#elif card["abilities"][ability]["name"] == "actions":
				#pass
			#elif card["abilities"][ability]["name"] == "efficient":
				#discount = card["abilities"][ability]["value"]
			#elif card["abilities"][ability]["value"] > 0:
				#card_effect_text += card["abilities"][ability]["name"].capitalize() + "-" \
				#+ str(int(card["abilities"][ability]["value"])) + " " 
		#new_card["card_effects"].text = card_effect_text
		#new_card["card_price"].text = str(int(card["cost"]))
		#card_number+=1
		#if card_number == 3:
			#card_number = 0

func add_unit_only_cards(parent,payload,type):
	print("parent: ", parent, " | payload: ", payload, " | type: ", type)
	var card_number = 0
	var row_node
	for card in payload["cards"]:
		if card_number == 0:
			row_node = HBoxContainer.new()
			parent.add_child(row_node)
			row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			row_node.add_theme_constant_override("separation",10)
		var new_card = CARD_SCENE.instantiate()
		row_node.add_child(new_card)
		new_card.define_scale(3)
		new_card.add_details(card)
		card_number+=1
		if card_number == 3:
			card_number = 0

#func add_unit_only_cards(parent,payload,type):
	#var card_number = 0
	#var row_node
	#for card in payload["cards"]:
		#if card_number == 0:
			#row_node = HBoxContainer.new()
			#parent.add_child(row_node)
			#row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			#row_node.add_theme_constant_override("separation",10)
		#var new_card = card_preview.instantiate()
		#row_node.add_child(new_card)
		#new_card["card_name"].text = card["card"]["name"]
		#new_card["card_type"].text = card["card"]["subtype"].capitalize()
		#new_card["card_id"] = card["id"]
		#new_card["type"] = type
		#new_card.connect("add_avatar_to_new_deck",avatar_to_new_deck)
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
		#new_card["card_effects"].text = card_effect_text
		#new_card["card_price"].text = str(int(card["card"]["cost"]-discount))
		#
		#for _child in new_card.card_color_profile.get_children():
			#new_card.card_color_profile.remove_child(_child)
			#_child.queue_free()
		#for color in card["card"]["color_profile"]:
			#var new_color = COLOR_PROFILE_SQUARE_LARGE.instantiate()
			#new_card.card_color_profile.add_child(new_color)
			#print(color)
			#new_color.color_square.color = Color(stats.COLOR_KEY[color["id"]])
			#new_color.color_magnitude.text = str(int(color["magnitude"]))
		#
		#card_number+=1
		#if card_number == 3:
			#card_number = 0

func add_to_deck(card_id):
	add_card_to_deck.emit(card_id)

func avatar_to_deck(card_id):
	add_avatar_to_deck.emit(card_id)

func avatar_to_new_deck(card_id):
	avatar_preview.show()
	na_label.hide()
	for row in cards_units_only_box.get_children():
		for card in row.get_children():
			if card.card_id == card_id:
				avatar_preview.card_name.text = card.card_name.text
				avatar_preview.card_price.text = card.card_price.text
				avatar_preview.card_attack.text = card.card_attack.text
				avatar_preview.card_health.text = card.card_health.text
				avatar_preview.card_effects.text = card.card_effects.text
	selected_avatar_id  = card_id

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

@warning_ignore("unused_parameter")
func _on_deck_name_text_changed(new_text):
	if deck_name.text != "":
		change_deck_name.emit(deck_name.text)

func _on_delete_deck_button_pressed():
	delete_deck.emit()
	deck_information.hide()

func _on_new_deck_button_pressed():
	show_units_only.emit()
	new_deck_name.text = ""
	new_deck_screen.show()

func _on_create_deck_button_pressed():
	if new_deck_name.text != "" and selected_avatar_id != 0:
		avatar_preview.hide()
		na_label.show()
		create_new_deck.emit(new_deck_name.text,selected_avatar_id)
		new_deck_screen.hide()
		selected_avatar_id = 0

#func add_avatar():
	#add_avatar_to_deck.emit(selected_avatar_id)

func _on_cancel_create_deck_button_pressed():
	avatar_preview.hide()
	na_label.show()
	new_deck_screen.hide()
