extends Control

var scene_name = "salvage_screen"

var stats = Stats
var utils = Utils

var KEYWORD_GLOSS = KeyWordGlossary

const ARE_YOU_SURE_POPUP = preload("res://items/are_you_sure_popup.tscn")
const SALVAGE_ITEM = preload("res://items/salvage_item.tscn")

@onready var background_color: ColorRect = $background_color
@onready var components_box: VBoxContainer = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/scroll_container/components_box
@onready var templates_box: VBoxContainer = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container2/scroll_container2/templates_box

func _ready() -> void:
	background_color.color = stats.background_color

func salvage_card_options(payload):
	var components_box_children = components_box.get_children()
	var templates_box_children = templates_box.get_children()
	for child in components_box_children:
		child.queue_free()
	for child in templates_box_children:
		child.queue_free()
	for component in payload["components"]:
		var new_component = SALVAGE_ITEM.instantiate()
		components_box.add_child(new_component)
		new_component["item_label"].text = component["name"]
		new_component["spin_box"].max_value = component["quantity_used"]
		new_component["amount_label"].text = "X%s" %[str(component["quantity_used"])]
		new_component["item_id"] = component["id"]
	for template in payload["templates"]:
		var new_template = SALVAGE_ITEM.instantiate()
		templates_box.add_child(new_template)
		new_template["item_label"].text = template["name"]
		new_template["spin_box"].max_value = 1
		new_template["amount_label"].text = "X1"
		new_template["item_id"] = template["id"]
