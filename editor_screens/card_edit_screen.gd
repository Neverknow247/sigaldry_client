extends Control

var scene_name = "card_edit"

var stats = Stats
var utils = Utils

const ARE_YOU_SURE_POPUP = preload("res://items/are_you_sure_popup.tscn")

@onready var background_color: ColorRect = $background_color
@onready var card: Control = $card
@onready var edit_name_button: Button = $edit_buttons/edit_name_button
@onready var edit_image_button: Button = $edit_buttons/edit_image_button
@onready var fusion_button: Button = $edit_buttons/fusion_button
@onready var duplicate_button: Button = $edit_buttons/duplicate_button
@onready var salvage_button: Button = $edit_buttons/salvage_button
@onready var scrap_button: Button = $edit_buttons/scrap_button

signal start_name_edit(_card_id)
signal start_image_edit(_card_id, _card_subtype)
signal start_fusion_edit(_card_id)
signal duplicate_card(_card_id)
signal salvage_card(_card_id)
signal scrap_card(_card_id)

var card_id = null
var card_subtype = null

func _ready():
	background_color.color = stats.background_color

func reset():
	card_id = null
	card_subtype = null

func get_info_card_edit(payload):
	#print(payload)
	set_up_buttons(payload["def"]["meta"],str(payload["def"]["name"]))
	card_id = payload["def"]["id"]
	card_subtype = payload["def"]["subtype"]
	card.add_details(payload["def"])
	card.show()

func set_up_buttons(payload, _name):
	if payload["can_change_image"]:
		edit_image_button.disabled = false
		if payload["image_status"] == "none":
			edit_image_button.text = "Add Image"
		else:
			edit_image_button.text = "Edit Image"
	else:
		edit_image_button.disabled = true
		edit_image_button.text = "Cannot Edit Image"
	if payload["can_change_name"]:
		edit_name_button.disabled = false
		if _name == "<null>":
			edit_name_button.text = "Add Name"
		else:
			edit_name_button.text = "Edit Name"
	else:
		edit_name_button.disabled = true
		edit_name_button.text = "Cannot Edit Name"
	if payload["can_duplicate"]:
		duplicate_button.disabled = false
		duplicate_button.text = "Duplicate Card"
	else:
		duplicate_button.disabled = true
		duplicate_button.text = "Cannot Duplicate"
	if payload["can_salvage"]:
		salvage_button.disabled = false
		salvage_button.text = "Salvage Card"
	else:
		salvage_button.disabled = true
		salvage_button.text = "Cannot Salvage Card"
	if payload["can_scrap"]:
		scrap_button.disabled = false
		scrap_button.text = "Scrap: %s"%(str(payload["scrap_value"]))
	else:
		scrap_button.disabled = true
	#edit_image_button.disabled = !payload["can_change_image"]
	#edit_name_button.disabled = !payload["can_change_name"]
	fusion_button.disabled = !payload["can_fuse"]

func _on_edit_name_button_pressed() -> void:
	start_name_edit.emit(card_id)

func _on_edit_image_button_pressed() -> void:
	start_image_edit.emit(card_id,card_subtype)

func _on_fusion_button_pressed() -> void:
	start_fusion_edit.emit(card_id)

func _on_duplicate_button_pressed() -> void:
	var popup_window = utils.instantiate_popup_on_world(ARE_YOU_SURE_POPUP)
	popup_window.are_you_sure_label.text = "Are you sure you want to Duplicate this card?\n
	This will consume the proper template and components."
	popup_window.connect("yes",_on_duplicate_card)

func _on_duplicate_card():
	duplicate_card.emit(card_id)

func _on_scrap_button_pressed() -> void:
	var popup_window = utils.instantiate_popup_on_world(ARE_YOU_SURE_POPUP)
	popup_window.are_you_sure_label.text = "Are you sure you want to Scrap this card?"
	popup_window.connect("yes",_on_scrap_card)

func _on_scrap_card():
	scrap_card.emit(card_id)

func _on_salvage_button_pressed() -> void:
	salvage_card.emit(card_id)
