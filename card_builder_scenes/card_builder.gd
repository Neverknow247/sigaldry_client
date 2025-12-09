extends Control

var scene_name = "card_builder"

var stats = Stats

var KEYWORD_GLOSS = KeyWordGlossary

const COLOR_PROFILE_SQUARE_LARGE = preload("res://items/color_profile_square_large.tscn")
const COMPONENT_BUTTON = preload("res://card_builder_scenes/component_button.tscn")

@onready var next_bonuses = {
	"r" : $card_grid/next_bonus_row/color_bonus_square,
	"o" : $card_grid/next_bonus_row/color_bonus_square2,
	"y" : $card_grid/next_bonus_row/color_bonus_square3,
	"g" : $card_grid/next_bonus_row/color_bonus_square4,
	"u" : $card_grid/next_bonus_row/color_bonus_square5,
	"p" : $card_grid/next_bonus_row/color_bonus_square6,
	"w" : $card_grid/next_bonus_row/color_bonus_square7,
	"b" : $card_grid/next_bonus_row/color_bonus_square8,
	"a" : $card_grid/next_bonus_row/color_bonus_square9
}

signal back_to_menu
signal template_selected(id)
signal component_selected(id)
signal component_removed
signal piece_rotate(direction)
signal piece_flip
@warning_ignore("unused_signal")
signal place_component
signal change_name(card_name)
signal save_card
signal move_set(data)
signal undo
signal restart
signal compare_card_select

@onready var background_color = $background_color
@onready var template_select_background: ColorRect = $template_select_overlay/template_select_background

@onready var template_select_overlay: Control = $template_select_overlay

@onready var card_select_background = $card_compare_screen/card_select_screen/card_select_background

@onready var card_grid = $card_grid
@onready var active_component = $card_grid/active_component
@onready var next_bonus_row = $card_grid/next_bonus_row

#@onready var template_select = $template_select

@onready var card_preview = $card_preview
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
var active_component_id = 0
var infinity_symbol = char(8734)

var components_color_dict = {
	"red":false,
	"orange":false,
	"yellow":false,
	"green":false,
	"blue":false,
	"purple":false,
	"white":false,
	"black":false,
	"gray":false
}

func _ready():
	background_color.color = stats.background_color
	template_select_background.color = stats.background_color
	card_select_background.color = stats.background_color
	#template_select.get_popup().max_size.y = 800

func _on_back_button_pressed():
	card_grid.active_component = false
	back_to_menu.emit()

func _on_template_type_back_button_pressed() -> void:
	card_grid.active_component = false
	back_to_menu.emit()

func reset_card_builder():
	template_select_overlay.set_up()
	template_select_overlay.show()
	next_bonus_row.hide()
	card_grid.active_component = false
	card_preview.hide()
	search_bar.text = ""
	#search_bar.hide()
	selected_template_num = 0
	selected_template_type = ""
	#template_select.selected = 0
	card_grid.reset_card_grid()
	active_component.reset_active_component()

var templates_dict = {}

func load_build_templates(payload):
	template_select_overlay.set_templates_dict(payload["templates"])

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
			print("**********************")
			print(component)
			print("**********************")
			
			var new_component_button = COMPONENT_BUTTON.instantiate()
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
			new_component_button.cost_label.text = str(component["cost"])
			#new_component_button.text = str(int(component["cost"]))+"\n"+component["name"].capitalize()
			new_component_button.amount_label.text = infinity_symbol if component["always_available"] else "X"+str(int(component["available"])-int(component["used"]))
			#new_component_button.amount_label.text = "X"+str(int(component["amount"]))
			#print(KEYWORD_GLOSS["key_glossary"])
			#if KEYWORD_GLOSS["key_glossary"].has([component["abilities"][0]["key"]]):
			
			#new_component_button.tooltip_text = KEYWORD_GLOSS["key_glossary"][component["abilities"][0]["key"]]["description"]
			var _tooltip_text = ""
			var words = KeyWordGlossary.key_glossary[component["abilities"][0]["key"]]["description"].split(" ")
			for word in words:
				var is_dependent = false
				var dependent_keyword
				var dependent_key
				if word[0] == "<": #and word[word.length()-1] == ">":
					#var key = word.substr(1,word.length() - 2)
					var key = word.substr(1,word.length() - (word.length() - word.find(">")) -1)
					is_dependent = true
					dependent_key = key
					dependent_keyword = KeyWordGlossary.key_glossary[key]["name"]
				if is_dependent:
					_tooltip_text += dependent_keyword.capitalize() + " "
				else:
					_tooltip_text += word + " "
			new_component_button.tooltip_text = _tooltip_text
			
			
			
			new_component_button.component_id = component["id"]
			new_component_button.connect("component_selected",on_component_selected)
			new_component_button.component_name = component["name"]
			new_component_button.component_color = component["color_profile"]["name"]
			new_component_button.color_profile_square.color_square.color = component["color_profile"]["background_color"]
			new_component_button.color_profile_square.color_magnitude.text = str(int(component['color_profile']['magnitude']))
			new_component_button.component_shape_grid.create_component_shapes(component)
	check_search_bar(search_bar.text)

func _on_search_bar_text_changed(new_text):
	check_search_bar(new_text)


var search_bar_string = ""
var new_string = ""
func check_search_bar(new_text):
	search_bar_string = new_text
	new_string = ""
	for i in new_text:
		if i == " ":
			pass
		else:
			new_string+=i
	set_up_component_select()

func set_up_component_select():
	var all_colors_false = true
	for color_key in components_color_dict:
		if components_color_dict[color_key] == true:
			all_colors_false = false
	var component_list = component_v_box.get_children()
	for component in component_list:
		component.show()
		if (components_color_dict[component.component_color] or all_colors_false) and \
		(component.component_name.containsn(search_bar_string) or \
		 component.component_color.containsn(search_bar_string) or \
		 new_string == ""):
			pass
		else:
			component.hide()

func card_builder_update_grid(payload):
	if payload:
		#print("update grid: ",payload)
		card_grid.create_card_grid(payload["grid"],payload["components"])
		if payload["active_component"]:
			card_grid.create_component_shapes(payload["active_component"])
			active_component.create_active_component(payload["active_component"])
		else:
			active_component.create_active_component({'shape':[],'x':'0','y':'0','color_profile':{'background_color':'FFFFFF'}})
		update_next_color_bonus(payload["last_color"])

func card_builder_update_card(payload):
	if payload["card"] == null:
		return
	var card_payload = payload
	card_payload["id"] = payload["card"]["id"]
	#print(payload)
	#print("HERE IS WHERE I NEED AN UPDATE:")
	card_preview.show()
	reset_card()
	#$card_preview/card.add_builder_details(card_payload)
	$card_preview/card.add_details(card_payload["card"])
	

func update_next_color_bonus(last_color):
	if !last_color:
		next_bonus_row.hide()
		return
	print("Last Color: ",last_color["bonus_to"])
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
			"1.0":
				next_bonuses[color].bonus_label.text = "100%"
			_:
				print("Unused Bonus: ",str(last_color["bonus_to"][color]))
				#print(str(last_color["bonus_to"][color]))
		#next_bonuses[color].bonus_label.text = str(last_color["bonus_to"][color])
		#next_bonuses[color].bonus_label.text = str(int(last_color["bonus_to"][color]))

func on_component_selected(id):
	active_component_id = id
	component_selected.emit(id)

func _on_clear_component_piece_button_pressed():
	component_removed.emit()

#func _on_place_component_button_pressed():
	#place_component.emit()

func _on_save_button_pressed():
	save_card.emit()
	#if $card_preview/name_card_edit.text != "":
		#save_card.emit()

func reset_card():
	card_name.text = ""
	card_effects.text = ""
	card_price.text = ""
	card_attack.text = ""
	card_health.text = ""

func _on_card_grid_check_placement_pos(default_pos,possible_pos):
	#var move_to = Vector2(possible_pos.x, possible_pos.y)
	var move_to = Vector2(possible_pos.x - default_pos.x, possible_pos.y - default_pos.y)
	#move_set.emit({"move_x":str(move_to.x),"move_y":str(move_to.y)})
	var data = {
		#"component_id": active_component_id,
		#"direction": 2,
		"position": {
			"x": possible_pos.x,
			"y": possible_pos.y
		},
		"commit": true
	}
	move_set.emit(data)

#func _on_card_grid_piece_rotate():
	#rotate_card.emit({"direction":"clockwise"})

func _on_card_grid_piece_rotate(_direction: Variant) -> void:
	piece_rotate.emit({"direction":_direction})

func _on_card_grid_piece_flip() -> void:
	piece_flip.emit()

func _on_card_grid_component_removed() -> void:
	component_removed.emit()

func _on_undo_button_pressed():
	undo.emit()

func _on_card_grid_active_component_changed(val):
	#template_select.visible = !val
	component_container.visible = !val
	clear_component_piece_button.visible = val
	if selected_template_type != "":
		search_bar.visible = !val

func _on_restart_button_pressed():
	restart.emit()

func _on_compare_card_select_button_pressed():
	compare_card_select.emit()

func view_cards(payload):
	#print("compare_card: ",payload," ******")
	card_select_screen.show()
	card_compare_screen.add_cards(payload)

func close():
	card_select_screen.hide()
	compare_card.hide()

func _on_template_select_overlay_template_selected(template_id: Variant, template_type: Variant) -> void:
	selected_template_num = template_id
	selected_template_type = template_type
	template_selected.emit(template_id)
	template_select_overlay.hide()

func _on_red_button_toggled(toggled_on: bool) -> void:
	components_color_dict["red"] = toggled_on
	set_up_component_select()

func _on_orange_button_toggled(toggled_on: bool) -> void:
	components_color_dict["orange"] = toggled_on
	set_up_component_select()

func _on_yellow_button_toggled(toggled_on: bool) -> void:
	components_color_dict["yellow"] = toggled_on
	set_up_component_select()

func _on_green_button_toggled(toggled_on: bool) -> void:
	components_color_dict["green"] = toggled_on
	set_up_component_select()

func _on_blue_button_toggled(toggled_on: bool) -> void:
	components_color_dict["blue"] = toggled_on
	set_up_component_select()

func _on_purple_button_toggled(toggled_on: bool) -> void:
	components_color_dict["purple"] = toggled_on
	set_up_component_select()

func _on_white_button_toggled(toggled_on: bool) -> void:
	components_color_dict["white"] = toggled_on
	set_up_component_select()

func _on_black_button_toggled(toggled_on: bool) -> void:
	components_color_dict["black"] = toggled_on
	set_up_component_select()

func _on_grey_button_toggled(toggled_on: bool) -> void:
	components_color_dict["gray"] = toggled_on
	set_up_component_select()
