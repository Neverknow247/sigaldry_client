extends HBoxContainer

const CARD_SCENE = preload("res://items/card.tscn")

var card_id

@onready var add_card_image_button: Button = $v_box_container/add_card_image_button
@onready var add_card_name_button: Button = $v_box_container/add_card_name_button

signal start_add_card_image(_id)
signal start_add_card_name(_id)

func add_card(card):
	card_id = card["id"]
	var new_card = CARD_SCENE.instantiate()
	add_child(new_card)
	move_child(new_card,0)
	new_card.define_scale(4)
	new_card.add_details(card)
	if card["meta"]["can_change_image"]:
		if card["meta"]["image_status"] == "none":
			add_card_image_button.show()
	if card["meta"]["can_change_name"]:
		add_card_name_button.show()

func _on_add_card_image_button_pressed() -> void:
	start_add_card_image.emit(card_id)

func _on_add_card_name_button_pressed() -> void:
	start_add_card_name.emit(card_id)
