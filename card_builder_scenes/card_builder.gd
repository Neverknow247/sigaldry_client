extends Control

var scene_name = "card_builder"

var stats = Stats

var KEYWORD_GLOSS = KeywordGloss.new()

const COLOR_PROFILE_SQUARE_LARGE = preload("res://items/color_profile_square_large.tscn")

@onready var next_bonuses = {
	"R" : $card_grid/next_bonus_row/color_bonus_square,
	"O" : $card_grid/next_bonus_row/color_bonus_square2,
	"Y" : $card_grid/next_bonus_row/color_bonus_square3,
	"G" : $card_grid/next_bonus_row/color_bonus_square4,
	"U" : $card_grid/next_bonus_row/color_bonus_square5,
	"P" : $card_grid/next_bonus_row/color_bonus_square6,
	"W" : $card_grid/next_bonus_row/color_bonus_square7,
	"B" : $card_grid/next_bonus_row/color_bonus_square8,
	"C" : $card_grid/next_bonus_row/color_bonus_square9
}

signal back_to_menu
signal template_selected(id)
signal component_selected(id)
signal component_removed
signal rotate_card(direction)
@warning_ignore("unused_signal")
signal place_component
signal change_name(card_name)
signal save_card
signal move_set(data)
signal undo
signal restart
signal compare_card_select

@onready var background_color = $background_color
@onready var card_select_background = $card_compare_screen/card_select_screen/card_select_background

@onready var card_grid = $card_grid
@onready var active_component = $card_grid/active_component
@onready var next_bonus_row = $card_grid/next_bonus_row

@onready var template_select = $template_select

@onready var card_preview = $card_preview
@onready var name_card_edit = $card_preview/name_card_edit
@onready var card_name = $card_preview/card_graphic/card_name
@onready var card_effects = $card_preview/card_graphic/card_effects
@onready var card_price = $card_preview/card_graphic/card_price
@onready var card_attack = $card_preview/card_graphic/card_attack
@onready var card_health = $card_preview/card_graphic/card_health
@onready var card_color_profile = $card_preview/card_graphic/card_color_profile

@onready var search_bar = $search_bar
@onready var component_container = $component_container
@onready var component_v_box = $component_container/component_v_box
@onready var clear_component_piece_button = $clear_component_piece_button

@onready var card_compare_screen = $card_compare_screen
@onready var card_select_screen = $card_compare_screen/card_select_screen
@onready var compare_card = $card_compare_screen/compare_card

var selected_template_num = 0
var selected_template_type = ""

func _ready():
	background_color.color = stats.background_color
	card_select_background.color = stats.background_color

func _on_back_button_pressed():
	card_grid.active_component = false
	back_to_menu.emit()

func reset_card_builder():
	next_bonus_row.hide()
	card_grid.active_component = false
	card_preview.hide()
	name_card_edit.text = ""
	search_bar.text = ""
	search_bar.hide()
	selected_template_num = 0
	selected_template_type = ""
	template_select.selected = 0
	card_grid.reset_card_grid()
	active_component.reset_active_component()

func load_build_templates(payload):
	var temp_num = 0
	var stage = 0
	template_select.clear()
	template_select.add_item("Pick A Template", -1)
	#template_select.add_separator()
	for item in payload["templates"]:
		temp_num += 1
		if item["name"].capitalize().contains("Order") && stage < 1:
			stage = 1
			template_select.add_separator()
			temp_num += 1
		elif item["name"].capitalize().contains("Blueprint") && stage < 2:
			stage = 2
			template_select.add_separator()
			temp_num += 1
		elif item["name"].capitalize().contains("Scroll") && stage < 3:
			stage = 3
			template_select.add_separator()
			temp_num += 1
		if item["active"]:
			selected_template_type = item["type"]
			selected_template_num = temp_num
		template_select.add_item(item["name"].capitalize(),item["id"])
	#print("selected: ", template_select.selected)
	template_select.selected = selected_template_num
		#if item["name"].contains("Legendary"):
			#template_select.add_separator()

@warning_ignore("unused_parameter")
func _on_template_select_item_selected(index):
	template_selected.emit(template_select.get_selected_id())

func load_builder_components(payload):
	#print(payload)
	var component_container_children = component_v_box.get_children()
	for child in component_container_children:
		child.queue_free()
	if payload["components"]:
		for component in payload["components"]:
			if component["prerequisites"].has("filters"):
				var is_in_filter = false
				for filter in component["prerequisites"]["filters"]:
					if filter["template"]["type"] == selected_template_type:
						is_in_filter = true
				if !is_in_filter:
					continue
			#if component["disabled"] or !KEYWORD_GLOSS.neverknow_approved_items.has(component["name"]):
				#continue
			#print("**********************")
			#print(component)
			#print("**********************")
			var component_button = preload("res://card_builder_scenes/component_button.tscn")
			var new_component_button = component_button.instantiate()
			component_v_box.add_child(new_component_button)
			var button_text_array = component["name"].capitalize().split(" ", true, 2)
			#print(button_text_array[1])
			var modified_bonus = float(button_text_array[1]) + (float(button_text_array[1]) * component["bonus"])
			new_component_button.button_label.text = button_text_array[0]+" "+button_text_array[1]
			#if float(button_text_array[1]) != modified_bonus:
			new_component_button.modifier_label.text = "+"+str(modified_bonus)
			#else:
				#new_component_button.modifier_label.text = ""
			#new_component_button.text = "\n"+component["name"].capitalize()
			new_component_button.cost_label.text = str(int(component["cost"]))
			#new_component_button.text = str(int(component["cost"]))+"\n"+component["name"].capitalize()
			new_component_button.amount_label.text = "X"+str(int(component["amount"]))
			new_component_button.tooltip_text = KEYWORD_GLOSS["glossary"][component["keywords"][0]["name"]]
			new_component_button.component_id = component["id"]
			new_component_button.connect("component_selected",on_component_selected)
			new_component_button.component_name = component["name"]
			new_component_button.component_color = component["color"]["name"]
			new_component_button.color_profile_square.color_square.color = component["color"]["background_color"]
			new_component_button.color_profile_square.color_magnitude.text = str(int(component['color']['magnitude']))
			new_component_button.component_shape_grid.create_component_shapes(component)
	check_search_bar(search_bar.text)

func _on_search_bar_text_changed(new_text):
	check_search_bar(new_text)

func check_search_bar(new_text):
	var new_string = ""
	for i in new_text:
		if i == " ":
			pass
		else:
			new_string+=i
	var component_list = component_v_box.get_children()
	for component in component_list:
		component.show()
		if component.component_name.containsn(new_text) or component.component_color.containsn(new_text) or new_string == "":
			pass
		else:
			component.hide()


func load_builder_grid(payload):
	#print(payload)
	if payload:
		print("Payload: ", payload["card"])
	if payload:
		card_grid.create_card_grid(payload["grid"],payload["card"]["card"]["components"])
		update_card_preview(payload["card"])
		#update_card_preview(payload["card"]["card"])
		if payload["active_component"]:
			card_grid.create_component_shapes(payload["active_component"])
			active_component.create_active_component(payload["active_component"])
		else:
			active_component.create_active_component({'shape':[],'x':'0','y':'0','color':{'background_color':"FFFFFF"}})
		update_next_color_bonus(payload["last_color"])

func update_next_color_bonus(last_color):
	#print(last_color["bonus_to"])
	next_bonus_row.show()
	for color in last_color["bonus_to"]:
		next_bonuses[color].bonus_color.color = stats.COLOR_KEY[color]
		match str(last_color["bonus_to"][color]):
			"-0.5":
				next_bonuses[color].bonus_label.text = "-50%"
			"-0.15":
				next_bonuses[color].bonus_label.text = "-15%"
			"0.0":
				next_bonuses[color].bonus_label.text = "0%"
			"0.15":
				next_bonuses[color].bonus_label.text = "15%"
			"0.5":
				next_bonuses[color].bonus_label.text = "50%"
			_:
				pass
				print(str(last_color["bonus_to"][color]))
		#next_bonuses[color].bonus_label.text = str(last_color["bonus_to"][color])
		#next_bonuses[color].bonus_label.text = str(int(last_color["bonus_to"][color]))

func on_component_selected(id):
	component_selected.emit(id)

func _on_clear_component_piece_button_pressed():
	component_removed.emit()

#func _on_place_component_button_pressed():
	#place_component.emit()

func _on_save_button_pressed():
	if $card_preview/name_card_edit.text != "":
		save_card.emit()

func update_card_preview(card_payload):
	print("HERE IS WHERE I NEED AN UPDATE:")
	#print(card_payload)
	#print("Name: ",card_payload["name"])
	#print("Unique Override: ",card_payload["unique_override"])
	#print("Unique Author: ",card_payload["unique_author"])
	#print("Unique Cost: ",card_payload["unique_cost"])
	name_card_edit.editable = true
	if card_payload["card"]["unique_author"] != "":
		name_card_edit.editable = false
		name_card_edit.text = card_payload["card"]["name"]
	else:
		pass
		#name_card_edit.text = ""
	card_preview.show()
	reset_card()
	$card_preview/card.add_builder_details(card_payload)
	#card_name.text = card_payload["name"]
	#var card_effect_text = ""
	#var discount = 0
	#if card_payload["obj"]["abilities"]:
		#for ability in card_payload["obj"]["abilities"]:
			#if ability == "health":
				#var card_hp = card_payload["obj"]["abilities"][ability]["value"]
				#card_health.text = str(int(card_hp)) if card_hp > 0 else ""
			#elif ability == "attack":
				#card_attack.text = str(int(card_payload["obj"]["abilities"][ability]["value"]))
			#elif ability == "actions":
				#pass
			#elif ability == "efficient":
				#discount = card_payload["obj"]["abilities"][ability]["value"]
			#elif card_payload["obj"]["abilities"][ability]["value"] > 0:
				#card_effect_text += card_payload["obj"]["abilities"][ability]["display_name"].capitalize() + "-" \
				#+ str(card_payload["obj"]["abilities"][ability]["value"]) + "  " 
				##+ str(int(card_payload["obj"]["abilities"][ability]["value"])) + "  " 
	#card_effects.text = card_effect_text
	#card_price.text = str(int(max(card_payload["true_cost"]-discount,0)))
	##card_price.text = str(int(card_payload["card"]["cost"]))
	##card_color_profile.columns = 1
	#for _child in card_color_profile.get_children():
		#card_color_profile.remove_child(_child)
		#_child.queue_free()
	#for color in card_payload["color_profile"]:
		#var new_color = COLOR_PROFILE_SQUARE_LARGE.instantiate()
		#card_color_profile.add_child(new_color)
		#new_color.color_square.color = Color(color["background_color"])
		#new_color.color_magnitude.text = str(int(color["magnitude"]))

#28/24
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

@warning_ignore("unused_parameter")
func _on_name_card_ed_text_changed(new_text):
	if $card_preview/name_card_edit.text != "":
		change_name.emit($card_preview/name_card_edit.text)

func _on_card_grid_active_component_changed(val):
	template_select.visible = !val
	component_container.visible = !val
	clear_component_piece_button.visible = val
	if selected_template_type != "":
		search_bar.visible = !val

func _on_restart_button_pressed():
	restart.emit()

func _on_compare_card_select_button_pressed():
	compare_card_select.emit()

func view_cards(payload):
	print("compare_card: ",payload," ******")
	card_select_screen.show()
	card_compare_screen.add_cards(payload)

func close():
	card_select_screen.hide()
	compare_card.hide()
