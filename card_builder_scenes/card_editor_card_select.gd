extends HBoxContainer

const CARD_SCENE = preload("res://items/card.tscn")

var card_id
var card_subtype

@onready var add_card_image_button: Button = $v_box_container/add_card_image_button
@onready var add_card_name_button: Button = $v_box_container/add_card_name_button

signal start_add_card_image(_id,_card_subtype)
signal start_add_card_name(_id)

func add_card(card,last_card):
	card_id = card["id"]
	var new_card = CARD_SCENE.instantiate()
	add_child(new_card)
	if last_card:
		new_card.last_card = true
	move_child(new_card,0)
	new_card.define_scale(4)
	new_card.add_details(card)
	if card["meta"]["can_change_name"]:
		add_card_name_button.show()
	match card["subtype"]:
		"avatar":
			card_subtype = "avatar"
		"unit":
			card_subtype = "unit"
		"trap":
			card_subtype = "trap"
			return
		"spell":
			card_subtype = "spell"
		"potion":
			card_subtype = "potion"
			return
		_:
			card_subtype = ""
			return
	#print("card subtype: ", card["subtype"])
	#if card["subtype"] != "unit" and card["subtype"] != "avatar" and card["subtype"] != "spell":
		#return
	if card["meta"]["can_change_image"]:
		if card["meta"]["image_status"] == "none":
			add_card_image_button.show()
		#add_card_image_button.show()

func _on_add_card_image_button_pressed() -> void:
	start_add_card_image.emit(card_id,card_subtype)

func _on_add_card_name_button_pressed() -> void:
	start_add_card_name.emit(card_id)
