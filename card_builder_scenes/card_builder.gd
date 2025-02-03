extends Control

var scene_name = "card_builder"

signal back_to_menu
signal template_selected(id)
signal set_component(id)
signal move_card(cords)
signal rotate_card(direction)
signal place_component
signal change_name(card_name)
signal save_card
signal move_set(data)
signal undo
signal restart

@onready var card_grid = $card_grid
@onready var active_component = $card_grid/active_component
@onready var template_select = $template_select

@onready var card_preview = $card_preview
@onready var card_name = $card_preview/card_graphic/card_name
@onready var card_effects = $card_preview/card_graphic/card_effects
@onready var card_price = $card_preview/card_graphic/card_price
@onready var card_attack = $card_preview/card_graphic/card_attack
@onready var card_health = $card_preview/card_graphic/card_health

@onready var component_container = $component_container


func _on_back_button_pressed():
	card_grid.active_component = false
	back_to_menu.emit()

func reset_card_builder():
	card_grid.active_component = false
	card_preview.hide()
	card_grid.reset_card_grid()
	active_component.reset_active_component()

func load_build_templates(payload):
	template_select.clear()
	template_select.add_item("Pick A Template", -1)
	template_select.add_separator()
	for item in payload["templates"]:
		template_select.add_item(item["name"],item["id"])
		if item["name"].contains("Legendary"):
			template_select.add_separator()

func _on_template_select_item_selected(index):
	template_selected.emit(template_select.get_selected_id())

func _on_place_component_button_pressed():
	place_component.emit()

func _on_save_button_pressed():
	if $card_preview/name_card_edit.text != "":
		save_card.emit()

func update_card_preview(card_payload):
	card_preview.show()
	reset_card()
	card_name.text = card_payload["name"]
	var card_effect_text = ""
	var discount = 0
	if card_payload["obj"]["abilities"]:
		for ability in card_payload["obj"]["abilities"]:
			if ability == "health":
				var card_hp = card_payload["obj"]["abilities"][ability]["value"]
				card_health.text = str(card_hp) if card_hp > 0 else ""
			elif ability == "attack":
				card_attack.text = str(card_payload["obj"]["abilities"][ability]["value"])
			elif ability == "actions":
				pass
			elif ability == "efficient":
				discount = card_payload["obj"]["abilities"][ability]["value"]
			elif card_payload["obj"]["abilities"][ability]["value"] > 0:
				card_effect_text += card_payload["obj"]["abilities"][ability]["display_name"].capitalize() + "-" \
				+ str(card_payload["obj"]["abilities"][ability]["value"]) + "  " 
	card_effects.text = card_effect_text
	card_price.text = str(max(card_payload["true_cost"]-discount,0))

func reset_card():
	card_name.text = ""
	card_effects.text = ""
	card_price.text = ""
	card_attack.text = ""
	card_health.text = ""

func _on_card_grid_check_placement_pos(default_pos,possible_pos):
	var move_to = Vector2(possible_pos.x - default_pos.x, possible_pos.y - default_pos.y)
	move_set.emit({"move_x":str(move_to.x),"move_y":str(move_to.y)})

func _on_card_grid_piece_rotate():
	rotate_card.emit({"direction":"clockwise"})

func _on_undo_button_pressed():
	undo.emit()

func _on_name_card_ed_text_changed(new_text):
	if $card_preview/name_card_edit.text != "":
		change_name.emit($card_preview/name_card_edit.text)

func _on_card_grid_active_component_changed(val):
	template_select.visible = !val
	component_container.visible = !val

func _on_restart_button_pressed():
	restart.emit()
