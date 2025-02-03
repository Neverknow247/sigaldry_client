extends Control

var scene_name = "card_select"

@onready var select_container = $ScrollContainer/select_container
@onready var selected_container = $ScrollContainer2/selected_container
@onready var done_button = $done_button

const card_preview = preload("res://items/card_preview.tscn")

var binder_width = 3
var cards_selected = false

signal card_select(id)
signal card_select_done

func update_cards(payload):
	for n in select_container.get_children():
		select_container.remove_child(n)
		n.queue_free()
	for n in selected_container.get_children():
		selected_container.remove_child(n)
		n.queue_free()
	var card_number = 0
	var row_node
	for card in payload["select_from"]:
		if card_number == 0:
			row_node = HBoxContainer.new()
			select_container.add_child(row_node)
			row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			row_node.add_theme_constant_override("separation",25)
		add_card(card,row_node)
		card_number+=1
		if card_number == binder_width:
			card_number = 0
	for card in payload["selected"]:
		add_card(card,selected_container)

func add_card(card,container):
	var new_card = card_preview.instantiate()
	container.add_child(new_card)
	new_card["card_name"].text = card["name"]
	new_card["card_id"] = card["id"]
	new_card["type"] = "card_select"
	new_card.connect("select_card",select_card)
	var card_effect_text = ""
	var discount = 0
	if card["abilities"]:
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
				card_effect_text += card["abilities"][ability]["name"].capitalize() + "-" \
				+ str(card["abilities"][ability]["value"]) + "  " 
	new_card["card_effects"].text = card_effect_text
	new_card["card_price"].text = str(card["cost"]-discount)

func countdown(payload):
	#print(payload)
	if cards_selected:
		done_button.text = "Waiting (%s)" %[str(payload["time_remaining"])]
	else:
		done_button.text = "Done (%s)" %[str(payload["time_remaining"])]

func _on_done_button_pressed():
	card_select_done.emit()
	cards_selected = true
	done_button.disabled = true

func select_card(id):
	card_select.emit(id)
