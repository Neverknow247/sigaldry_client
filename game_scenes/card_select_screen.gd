extends Control

var scene_name = "card_select"

var stats = Stats

@onready var background_color = $background_color

@onready var select_container = $ScrollContainer/select_container
@onready var selected_container = $ScrollContainer2/selected_container
@onready var done_button = $done_button
@onready var finish_selection_screen_1 = $ScrollContainer/finish_selection_screen1
@onready var finish_selection_screen_2 = $ScrollContainer2/finish_selection_screen2

const CARD_SCENE = preload("res://items/card.tscn")

var binder_width = 4
var selected_width = 2
var cards_selected = false

signal card_select(id)
signal card_select_done

func _ready():
	background_color.color = stats.background_color

func reset():
	cards_selected = false
	done_button.disabled = false
	finish_selection_screen_1.hide()
	finish_selection_screen_2.hide()

func update_cards(payload):
	for i in payload:
		print(i)
	$Label.text = "Select up to %s cards for your opening hand"%[str(int(payload["max_cards"]))]
	for n in select_container.get_children():
		select_container.remove_child(n)
		n.queue_free()
	for n in selected_container.get_children():
		selected_container.remove_child(n)
		n.queue_free()
	var select_from_card_number = 0
	var selected_card_number = 0
	var select_from_row_node
	var selected_row_node
	for card in payload["select_from"]:
		if select_from_card_number == 0:
			select_from_row_node = HBoxContainer.new()
			select_container.add_child(select_from_row_node)
			select_from_row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			select_from_row_node.add_theme_constant_override("separation",25)
		var new_card = add_card(card,select_from_row_node)
		select_from_card_number += 1
		if select_from_card_number == binder_width:
			new_card.last_card  = true
			select_from_card_number = 0
	for card in payload["selected"]:
		if selected_card_number == 0:
			selected_row_node = HBoxContainer.new()
			selected_container.add_child(selected_row_node)
			selected_row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			selected_row_node.add_theme_constant_override("separation",25)
		var new_card = add_card(card,selected_row_node)
		selected_card_number += 1
		if selected_card_number == selected_width:
			new_card.last_card  = true
			selected_card_number = 0

func add_card(card,container):
	var new_card = CARD_SCENE.instantiate()
	container.add_child(new_card)
	new_card.define_scale(3)
	new_card.add_details(card)
	new_card.card_button_type = "select"
	new_card.connect("select_card",select_card)
	return new_card

func countdown(payload):
	if cards_selected:
		done_button.text = "Waiting (%s)" %[str(int(payload["time_remaining"]))]
	else:
		done_button.text = "Done (%s)" %[str(int(payload["time_remaining"]))]

func _on_done_button_pressed():
	card_select_done.emit()
	cards_selected = true
	done_button.disabled = true
	finish_selection_screen_1.show()
	finish_selection_screen_2.show()

func select_card(id):
	card_select.emit(id)
