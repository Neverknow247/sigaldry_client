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
#signal show_units_only
signal start_create_new_deck
signal avatar_selected(_card_id)

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
@onready var avatar_preview: Control = $new_deck_screen/CenterContainer2/HBoxContainer/VBoxContainer/CenterContainer/avatar_card_box/avatar_preview

var selected_avatar_id = 0

func _ready():
	avatar_preview.define_scale(5)
	avatar_preview.hide()
	color_background.color = stats.background_color
	new_deck_screen.color = stats.background_color

func _on_back_button_pressed():
	#avatar_preview.hide()
	avatar_preview.hide()
	na_label.show()
	close_deck_editor.emit()

func update_cards_in_deck(payload):
	clear_cards(cards_in_deck_box)
	if payload:
		add_cards(cards_in_deck_box,payload,"deck_editor_in_deck")

func update_cards_not_in_deck(payload):
	clear_cards(cards_not_in_deck_box)
	if payload:
		#print(payload)
		add_cards(cards_not_in_deck_box,payload,"deck_editor_not_in_deck")

func update_cards_unit_only(payload):
	clear_cards(cards_units_only_box)
	if payload:
		add_unit_only_cards(cards_units_only_box,payload,"unit_only")

func start_new_deck(payload):
	clear_cards(cards_units_only_box)
	if payload:
		add_unit_only_cards(cards_units_only_box, payload, "avatar")

func clear_cards(parent):
	for n in parent.get_children():
		parent.remove_child(n)
		n.queue_free()

func add_cards(parent,payload,type):
	if !payload["cards"] :
		return
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
		if type == "deck_editor_in_deck" and int(card["id"]) == int(payload["avatar_id"]):
			new_card["card_button_type"] = "avatar_deck_editor_in_deck"
			new_card.set_avatar()
		else:
			new_card["card_button_type"] = type
		new_card.connect("add_to_deck",add_to_deck)
		new_card.connect("remove_from_deck",remove_from_deck)
		card_number+=1
		if card_number == 3:
			new_card.last_card = true
			card_number = 0

func card_avatar_selected(payload):
	selected_avatar_id  = payload["def"]["id"]
	na_label.hide()
	avatar_preview.add_details(payload["def"])
	avatar_preview.show()


func add_unit_only_cards(parent,payload,type):
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
		new_card.card_button_type = "select"
		#new_card.connect("select_card",select_card)
		new_card.connect("select_card",avatar_to_new_deck)
		card_number+=1
		if card_number == 3:
			new_card.last_card = true
			card_number = 0

func add_to_deck(card_id):
	add_card_to_deck.emit(card_id)

#func avatar_to_deck(card_id):
	#add_avatar_to_deck.emit(card_id)

func avatar_to_new_deck(card_id):
	avatar_selected.emit(card_id)

func remove_from_deck(card_id):
	remove_card_from_deck.emit(card_id)

func start_deck_editor(payload):
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

@warning_ignore("unused_parameter")
func _on_deck_name_text_changed(new_text):
	if deck_name.text != "":
		change_deck_name.emit(deck_name.text)

func _on_delete_deck_button_pressed():
	delete_deck.emit()
	deck_information.hide()

func _on_new_deck_button_pressed():
	start_create_new_deck.emit()
	#show_units_only.emit()
	new_deck_name.text = ""
	new_deck_screen.show()

func _on_create_deck_button_pressed():
	if new_deck_name.text != "" and selected_avatar_id != 0:
		avatar_preview.hide()
		na_label.show()
		create_new_deck.emit(new_deck_name.text,selected_avatar_id)
		new_deck_screen.hide()
		selected_avatar_id = 0

func _on_cancel_create_deck_button_pressed():
	avatar_preview.hide()
	na_label.show()
	new_deck_screen.hide()
