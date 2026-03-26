extends Control

var scene_name = "card_fusion"

const CARD_SCENE = preload("res://items/card.tscn")
const ARE_YOU_SURE_POPUP = preload("res://items/are_you_sure_popup.tscn")

var stats = Stats
var utils = Utils
var KEYWORD_GLOSS = KeyWordGlossary

@onready var background_color: ColorRect = $background_color
@onready var v_box_container: VBoxContainer = $select_card_screen/margin_container/scroll_container/v_box_container

@onready var card_1: Control = $fusion_area/margin_container/v_box_container/h_box_container/card_1_v_box/card_1_area/card_1
@onready var card_2: Control = $fusion_area/margin_container/v_box_container/h_box_container/card_2_v_box/card_2_area/card_2
@onready var fusion_card_preview: Control = $fusion_area/margin_container/v_box_container/h_box_container/fusion_preview/fusion_card_preview_area/fusion_card_preview
@onready var card_1_back: TextureRect = $fusion_area/margin_container/v_box_container/h_box_container/card_1_v_box/card_1_area/card_1_back
@onready var card_2_back: TextureRect = $fusion_area/margin_container/v_box_container/h_box_container/card_2_v_box/card_2_area/card_2_back
@onready var fusion_card_back: TextureRect = $fusion_area/margin_container/v_box_container/h_box_container/fusion_preview/fusion_card_preview_area/fusion_card_back

@onready var fuse_button: Button = $fusion_area/margin_container/v_box_container/h_box_container2/fuse_button

@onready var select_card_screen: Control = $select_card_screen

signal select_fusion_card(_card_num,_id)
signal preview_fused_card(_card_id_1, _card_id_2)
signal fuse_cards(_card_id_1, _card_id_2)

var fusion_subtype = null
var selected_preview_card = null
var card_id_1 = null
var card_id_2 = null

var binder = []
var binder_sorted = []
var binder_width = 5

func _ready():
	background_color.color = stats.background_color
	reset()

func reset():
	fusion_subtype = null
	selected_preview_card = null
	card_id_1 = null
	card_id_2 = null
	card_1.hide()
	card_1_back.show()
	card_2.hide()
	card_2_back.show()
	fusion_card_preview.hide()
	fusion_card_back.show()
	select_card_screen.hide()
	fuse_button.disabled = true

func store_items(payload):
	reset()
	binder = []
	for card in payload["cards"]:
		binder.append(card)
	binder_sorted = binder.duplicate(true)
	add_cards()

func add_cards():
	for n in v_box_container.get_children():
		v_box_container.remove_child(n)
		n.queue_free()
	var card_number = 0
	var row_node
	var first_card = true
	var true_binder = binder_sorted.duplicate(true)
	for card in true_binder:
		if card["id"] == card_id_1 || card["id"] == card_id_2:
			continue
		if !card["meta"]["can_fuse"]:
			continue
		if first_card:
			first_card = false
		if card_number == 0:
			row_node = HBoxContainer.new()
			v_box_container.add_child(row_node)
			row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			row_node.add_theme_constant_override("separation",25)
		var new_card = CARD_SCENE.instantiate()
		row_node.add_child(new_card)
		new_card.define_scale(4)
		new_card.add_details(card)
		new_card["card_button_type"] = "preview_select"
		new_card.connect("compare_card",add_preview_card)
		card_number+=1
		if card_number == binder_width:
			new_card.last_card  = true
			card_number = 0

func add_preview_card(card_id):
	select_fusion_card.emit(selected_preview_card,card_id)
	#match selected_preview_card:
		#"card_1":
			#select_fusion_card.emit("card_1",card_id)
		#"card_2":
			#select_fusion_card.emit("card_2",card_id)

func set_fusion_card(card_num,payload):
	select_card_screen.hide()
	selected_preview_card = null
	match card_num:
		"card_1":
			card_id_1 = payload["def"]["id"]
			fusion_subtype = payload["def"]["subtype"]
			card_1.add_details(payload["def"])
			card_1.show()
			card_1_back.hide()
			check_fusion_preview()
			sort_binder()
		"card_2":
			card_id_2 = payload["def"]["id"]
			fusion_subtype = payload["def"]["subtype"]
			card_2.add_details(payload["def"])
			card_2.show()
			card_2_back.hide()
			check_fusion_preview()
			sort_binder()
		"fusion_card":
			#print(payload)
			fusion_card_preview.add_details(payload["fused_card"])
			fusion_card_preview.show()
			fusion_card_back.hide()
	#sort_binder()
	#check_fusion_preview()

func sort_binder():
	binder_sorted = []
	match fusion_subtype:
		"unit":
			for card in binder:
				if card["subtype"] == "unit":
					binder_sorted.append(card)
		"potion":
			for card in binder:
				if card["subtype"] == "potion":
					binder_sorted.append(card)
		"spell":
			for card in binder:
				if card["subtype"] == "spell":
					binder_sorted.append(card)
		"trap":
			for card in binder:
				if card["subtype"] == "trap":
					binder_sorted.append(card)
		_:
			binder_sorted = binder.duplicate(true)
	binder_sorted.sort_custom(sort_alphabetically)
	add_cards()

func sort_alphabetically(a,b):
	var card_a = a.get("name") if a.get("name") != null else ""
	var card_b = b.get("name") if b.get("name") != null else ""
	return card_a.to_lower() < card_b.to_lower()

func check_fusion_preview():
	if card_id_1 != null and card_id_2 != null:
		preview_fused_card.emit(card_id_1,card_id_2)
		fuse_button.disabled = false

func _on_select_card_1_button_pressed() -> void:
	selected_preview_card  = "card_1"
	select_card_screen.show()

func _on_select_card_2_button_pressed() -> void:
	selected_preview_card  = "card_2"
	select_card_screen.show()

func _on_fuse_button_pressed() -> void:
	var popup_window = utils.instantiate_popup_on_world(ARE_YOU_SURE_POPUP)
	popup_window.are_you_sure_label.text = "are you sure you want to fuse these cards?"
	popup_window.connect("yes",fuse_cards_confirm)

func fuse_cards_confirm():
	fuse_cards.emit(card_id_1,card_id_2)

func _on_reset_button_pressed() -> void:
	reset()
	sort_binder()
