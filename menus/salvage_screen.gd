extends Control

var scene_name = "salvage_screen"

var stats = Stats
var utils = Utils

var KEYWORD_GLOSS = KeyWordGlossary

const ARE_YOU_SURE_POPUP = preload("res://items/are_you_sure_popup.tscn")
const SALVAGE_ITEM = preload("res://items/salvage_item.tscn")

@onready var background_color: ColorRect = $background_color
@onready var templates_container: VBoxContainer = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/templates_container
@onready var template_item: Control = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/templates_container/template_item
@onready var no_template_item: Control = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/templates_container/no_template_item
@onready var template_label: Label = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/templates_container/template_item/control/template_label
@onready var start_bonus_container: HBoxContainer = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/templates_container/template_item/control/v_box_container/start_bonus_container
@onready var start_label: Label = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/templates_container/template_item/control/v_box_container/start_bonus_container/start_label
@onready var start_label_2: Label = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/templates_container/template_item/control/v_box_container/start_bonus_container/start_label2
@onready var start_color_bonus_square: ColorRect = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/templates_container/template_item/control/v_box_container/start_bonus_container/start_color_bonus_square
@onready var end_bonus_container: HBoxContainer = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/templates_container/template_item/control/v_box_container/end_bonus_container
@onready var end_label: Label = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/templates_container/template_item/control/v_box_container/end_bonus_container/end_label
@onready var end_label_2: Label = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/templates_container/template_item/control/v_box_container/end_bonus_container/end_label2
@onready var end_color_bonus_square: ColorRect = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/templates_container/template_item/control/v_box_container/end_bonus_container/end_color_bonus_square
@onready var component_items: ScrollContainer = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/components_container/component_items
@onready var components_box: GridContainer = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/components_container/component_items/components_box
@onready var no_component_items: Control = $salvage_area/margin_container/v_box_container/h_box_container/v_box_container/components_container/no_component_items
@onready var card: Control = $salvage_area/margin_container/v_box_container/h_box_container/card_preview/card

var card_id = 0
var template_id = 0
var salvage_items = {}
var individual_item = {"value":0}

signal salvage(_card_id,_components,_templates)

func _ready() -> void:
	background_color.color = stats.background_color

func reset():
	template_id = 0
	salvage_items = {}
	template_item.hide()
	no_template_item.show()
	component_items.hide()
	no_component_items.show()

func get_info_card_salvage(payload):
	card.add_details(payload["def"])
	card_id = payload["def"]["id"]

func salvage_card_options(payload):
	reset()
	var components_box_children = components_box.get_children()
	for child in components_box_children:
		child.queue_free()
	for component in payload["components"]:
		no_component_items.hide()
		component_items.show()
		var new_component = SALVAGE_ITEM.instantiate()
		components_box.add_child(new_component)
		new_component["item_label"].text = component["name"]
		new_component["spin_box"].max_value = component["quantity_used"]
		new_component["amount_label"].text = "X%s" %[str(component["quantity_used"])]
		new_component["item_id"] = component["id"]
		new_component.connect("value_changed",salvage_item_value_changed)
		salvage_items[component["id"]] = individual_item.duplicate(true)
	for template in payload["templates"]:
		no_template_item.hide()
		template_item.show()
		template_label.text = template["name"]
		if str(template["start_color"]) == "<null>":
			start_color_bonus_square.hide()
			start_label_2.show()
		else:
			start_color_bonus_square["bonus_label"].text = template["start_color"].capitalize()
			start_color_bonus_square["bonus_color"].color = stats.COLOR_KEY[template["start_color"]]
			start_label_2.hide()
			start_color_bonus_square.show()
		if str(template["end_color"]) == "<null>":
			end_color_bonus_square.hide()
			end_label_2.show()
		else:
			end_color_bonus_square["bonus_label"].text = template["end_color"].capitalize()
			end_color_bonus_square["bonus_color"].color = stats.COLOR_KEY[template["end_color"]]
			end_label_2.hide()
			end_color_bonus_square.show()
		template_id = template["id"]
		salvage_items[template["id"]] = individual_item.duplicate(true)

func _on_template_check_box_toggled(toggled_on: bool) -> void:
	match toggled_on:
		true:
			salvage_items[template_id]["value"] = 1
		false:
			salvage_items[template_id]["value"] = 0

func salvage_item_value_changed(_item_id,_value):
	salvage_items[_item_id]["value"] = _value

func _on_salvage_button_pressed() -> void:
	var selected_salvaged_components = []
	var selected_salvaged_templates = []
	for item in salvage_items:
		if salvage_items[item]["value"] > 0:
			if item == template_id:
				selected_salvaged_templates.append({"id":item,"quantity":salvage_items[item]["value"]})
			else:
				selected_salvaged_components.append({"id":item,"quantity":salvage_items[item]["value"]})
	salvage.emit(card_id,selected_salvaged_components,selected_salvaged_templates)
