extends Control

var scene_name = "card_view"

var stats = Stats

const CARD_SCENE = preload("res://items/card.tscn")

var binder = []
var binder_sorted = []
var hide_duplicates = true
var all_card_ids = []

var binder_ascending = true
var binder_width = 5
var binder_seperation = 36
#var binder_seperation = 25

@onready var background_color = $background_color

@onready var sort_style_button: OptionButton = $collection_sort/sort_style_button
@onready var sort_order_button: OptionButton = $collection_sort/sort_order_button
@onready var sort_restrictions_button: OptionButton = $collection_sort/sort_restrictions_button

@onready var scroll_container = $ScrollContainer
@onready var v_box_container = $ScrollContainer/VBoxContainer

signal exit_menu
signal start_edit_card(_id)

func _ready():
	background_color.color = stats.background_color

func store_items(payload):
	binder = []
	#binder_ascending = true
	for card in payload["cards"]:
		binder.append(card)
	
	_on_sort_restrictions_button_item_selected(sort_restrictions_button.get_selected_id())
	#binder_sorted = binder.duplicate(true)
	#add_cards()

func add_cards():
	all_card_ids = []
	for n in v_box_container.get_children():
		v_box_container.remove_child(n)
		n.queue_free()
	var card_number = 0
	var row_node
	var first_card = true
	var true_binder = binder_sorted.duplicate(true)
	if !binder_ascending: true_binder.reverse()
	for card in true_binder:
		#print(card)
		if all_card_ids.has(card["key"]) and hide_duplicates:
			continue
		all_card_ids.append(card["key"])
		if first_card:
			first_card = false
		if card_number == 0:
			row_node = HBoxContainer.new()
			v_box_container.add_child(row_node)
			#row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			row_node.add_theme_constant_override("separation", binder_seperation)
		var new_card = CARD_SCENE.instantiate()
		row_node.add_child(new_card)
		new_card.define_scale(4)
		new_card.add_details(card)
		new_card["card_button_type"] = "collection"
		new_card["start_edit_card"].connect(edit_card)
		card_number+=1
		if card_number == binder_width:
			new_card.last_card  = true
			card_number = 0

func edit_card(_id):
	start_edit_card.emit(_id)

func _on_back_button_pressed():
	exit_menu.emit()

func _on_sort_style_button_item_selected(index: int) -> void:
	match index:
		0 : binder_sorted.sort_custom(sort_alphabetically)
		1 : binder_sorted.sort_custom(sort_id)
		2 : binder_sorted.sort_custom(sort_subtype)
	add_cards()

func _on_sort_order_button_item_selected(index: int) -> void:
	match index:
		0 : binder_ascending = true
		1 : binder_ascending = false
	add_cards()

func _on_sort_restrictions_button_item_selected(index: int) -> void:
	binder_sorted = []
	match index:
		0 : binder_sorted = binder.duplicate(true)
		1 : 
			for card in binder:
				if card["subtype"] == "avatar":
					binder_sorted.append(card)
		2 :
			for card in binder:
				if card["subtype"] == "potion":
					binder_sorted.append(card)
		3 :
			for card in binder:
				if card["subtype"] == "spell":
					binder_sorted.append(card)
		4 :
			for card in binder:
				if card["subtype"] == "trap":
					binder_sorted.append(card)
		5 : 
			for card in binder:
				if card["subtype"] == "unit":
					binder_sorted.append(card)
		6 :
			for card in binder:
				if card["meta"]["can_change_name"] == true && str(card["name"]) == "<null>":
					binder_sorted.append(card)
		7 :
			for card in binder:
				if card["meta"]["can_change_image"] == true && str(card["image"]) == "<null>":
					binder_sorted.append(card)
		8 :
			print("here")
			for card in binder:
				if card["meta"]["designer"]["user_name"] == card["meta"]["owner"]["user_name"]:
					if card["name"] == "Baby Devil":
						print(card)
					binder_sorted.append(card)
	_on_sort_style_button_item_selected(sort_style_button.get_selected_id())

func _on_no_repeat_button_item_selected(index: int) -> void:
	match index:
		0:
			hide_duplicates = true
		1: 
			hide_duplicates = false
	add_cards()

func sort_id(a,b):
	var card_a = a.get("id") if a.get("id") != null else ""
	var card_b = b.get("id") if b.get("id") != null else ""
	return card_a < card_b

func sort_alphabetically(a,b):
	var card_a = a.get("name") if a.get("name") != null else ""
	var card_b = b.get("name") if b.get("name") != null else ""
	return card_a.to_lower() < card_b.to_lower()

func sort_subtype(a,b):
	var card_a = a.get("subtype") if a.get("subtype") != null else ""
	var card_b = b.get("subtype") if b.get("subtype") != null else ""
	return card_a.to_lower() < card_b.to_lower()
