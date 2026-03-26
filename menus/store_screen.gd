extends Control

var scene_name = "store"

var stats = Stats
var utils = Utils

var KEYWORD_GLOSS = KeyWordGlossary

const ARE_YOU_SURE_POPUP = preload("res://items/are_you_sure_popup.tscn")
const STORE_ITEM = preload("res://items/store_item.tscn")
const STORE_CATEGORY = preload("res://items/store_category.tscn")

@onready var background_color: ColorRect = $background_color
@onready var store_category_area: Control = $store_category_area
@onready var store_category_background: ColorRect = $store_category_area/store_category_background
@onready var store_categories_container: HBoxContainer = $store_category_area/margin_container/scroll_container/store_categories_container
@onready var store_items_container: VBoxContainer = $store_area/margin_container/scroll_container/store_items_container

var selected_key = null
var selected_quantity = null
signal buy_item(_item_key,_item_quantity)
signal category_selected(_category_id)

func _ready():
	background_color.color = stats.background_color
	store_category_background.color = stats.background_color

func store_get_categories(payload):
	#utils.j_print(payload)
	store_category_area.show()
	var store_categories_container_children = store_categories_container.get_children()
	for child in store_categories_container_children:
		child.queue_free()
	for category in payload["categories"]:
		var new_store_category = STORE_CATEGORY.instantiate()
		store_categories_container.add_child(new_store_category)
		new_store_category.category_label.text = category["name"]
		new_store_category.category_id = category["id"]
		new_store_category.tooltip_text = category["description"]
		new_store_category.connect("category_selected",select_category)

func select_category(_category_id):
	category_selected.emit(_category_id)

func store_get_containers(payload):
	store_category_area.hide()
	#utils.j_print(payload)
	var store_items_container_children = store_items_container.get_children()
	for child in store_items_container_children:
		child.queue_free()
	for container in payload["containers"]:
		#if container["id"] < 129:
			#continue
		var new_store_item = STORE_ITEM.instantiate()
		store_items_container.add_child(new_store_item)
		new_store_item.name_label.text = container["name"]
		new_store_item.cost_label.text = str(container["cost"]["standard_currency"])
		new_store_item.item_key = container["key"]
		new_store_item.connect("item_selected",select_item)

func select_item(_item_key,_item_quantity):
	selected_key = _item_key
	selected_quantity = _item_quantity
	var popup_window = utils.instantiate_popup_on_world(ARE_YOU_SURE_POPUP)
	popup_window.are_you_sure_label.text = "are you sure you want to buy this?"
	popup_window.connect("yes",buy_selected_key)

func buy_selected_key():
	buy_item.emit(selected_key,selected_quantity)

func reset_containers():
	selected_key = null
	selected_quantity = null
	for child in store_items_container.get_children():
		child.spin_box.value = 1
