extends Control

var stats = Stats

const TEMPLATE_BUTTON = preload("res://card_builder_scenes/template_button.tscn")

@onready var template_select: VBoxContainer = $h_box_container/scroll_container/template_select

#@onready var order_amount: Label = $h_box_container/v_box_container/v_box_container/order_select_button/v_box_container/amount
#@onready var blueprint_amount: Label = $h_box_container/v_box_container/v_box_container/blueprint_select_button/v_box_container/amount
#@onready var scroll_amount: Label = $h_box_container/v_box_container/v_box_container/scroll_select_button/v_box_container/amount
#@onready var formula_amount: Label = $h_box_container/v_box_container/v_box_container/formula_select_button/v_box_container/amount
#@onready var mirror_amount: Label = $h_box_container/v_box_container/v_box_container/mirror_select_button/v_box_container/amount

@onready var amounts = {
	"order" : $h_box_container/v_box_container/v_box_container/order_select_button/v_box_container/amount,
	"blueprint" : $h_box_container/v_box_container/v_box_container/blueprint_select_button/v_box_container/amount,
	"scroll" : $h_box_container/v_box_container/v_box_container/scroll_select_button/v_box_container/amount,
	"formula" : $h_box_container/v_box_container/v_box_container/formula_select_button/v_box_container/amount,
	"mirror" : $h_box_container/v_box_container/v_box_container/mirror_select_button/v_box_container/amount,
}
@onready var start_null_button: CheckButton = $h_box_container/v_box_container/start_color_container/start_null_button
@onready var start_red_button: CheckButton = $h_box_container/v_box_container/start_color_container/start_red_button
@onready var start_orange_button: CheckButton = $h_box_container/v_box_container/start_color_container/start_orange_button
@onready var start_yellow_button: CheckButton = $h_box_container/v_box_container/start_color_container/start_yellow_button
@onready var start_green_button: CheckButton = $h_box_container/v_box_container/start_color_container/start_green_button
@onready var start_blue_button: CheckButton = $h_box_container/v_box_container/start_color_container/start_blue_button
@onready var start_purple_button: CheckButton = $h_box_container/v_box_container/start_color_container/start_purple_button
@onready var start_white_button: CheckButton = $h_box_container/v_box_container/start_color_container/start_white_button
@onready var start_black_button: CheckButton = $h_box_container/v_box_container/start_color_container/start_black_button
@onready var start_all_button: CheckButton = $h_box_container/v_box_container/start_color_container/start_all_button

@onready var end_null_button: CheckButton = $h_box_container/v_box_container/end_color_container/end_null_button
@onready var end_red_button: CheckButton = $h_box_container/v_box_container/end_color_container/end_red_button
@onready var end_orange_button: CheckButton = $h_box_container/v_box_container/end_color_container/end_orange_button
@onready var end_yellow_button: CheckButton = $h_box_container/v_box_container/end_color_container/end_yellow_button
@onready var end_green_button: CheckButton = $h_box_container/v_box_container/end_color_container/end_green_button
@onready var end_blue_button: CheckButton = $h_box_container/v_box_container/end_color_container/end_blue_button
@onready var end_purple_button: CheckButton = $h_box_container/v_box_container/end_color_container/end_purple_button
@onready var end_white_button: CheckButton = $h_box_container/v_box_container/end_color_container/end_white_button
@onready var end_black_button: CheckButton = $h_box_container/v_box_container/end_color_container/end_black_button
@onready var end_all_button: CheckButton = $h_box_container/v_box_container/end_color_container/end_all_button


var template_type_selected = ""
var builder_templates = {
	"order":[],
	"blueprint":[],
	"scroll":[],
	"formula":[],
	"mirror":[]
}
var builder_templates_sorted = {
	"order":0,
	"blueprint":0,
	"scroll":0,
	"formula":0,
	"mirror":0
}
var rarity_dict = {
	"common":true,
	"uncommon":true,
	"rare":true,
	"epic":true,
	"legendary":true
}
@onready var start_color_buttons = [
	start_null_button,
	start_red_button,start_orange_button,start_yellow_button,start_green_button,
	start_blue_button,start_purple_button,start_white_button,start_black_button,
	start_all_button
]
var start_color_dict = {
	"<null>":false,
	"r":false,
	"o":false,
	"y":false,
	"g":false,
	"u":false,
	"p":false,
	"w":false,
	"b":false,
	#"a":false,
	#"n":false,
	#"k":false
}
@onready var end_color_buttons = [
	end_null_button,
	end_red_button,end_orange_button,end_yellow_button,end_green_button,
	end_blue_button,end_purple_button,end_white_button,end_black_button,
	end_all_button
]
var end_color_dict = {
	"<null>":false,
	"r":false,
	"o":false,
	"y":false,
	"g":false,
	"u":false,
	"p":false,
	"w":false,
	"b":false,
	#"a":false,
	#"n":false,
	#"k":false
}

var color_index_dict = {
	0:"",
	1:"<null>",
	2:"r",
	3:"o",
	4:"y",
	5:"g",
	6:"u",
	7:"p",
	8:"w",
	9:"b",
	10:"a"
}

var infinity_symbol = char(8734)

signal template_selected(template_id,template_type,start_color,end_color)

func set_up():
	template_type_selected = ""
	set_up_template_select()

func set_templates_dict(templates):
	#print(templates)
	builder_templates = {
		"order":[],
		"blueprint":[],
		"scroll":[],
		"formula":[],
		"mirror":[]
		}
	builder_templates_sorted = {
		"order":0,
		"blueprint":0,
		"scroll":0,
		"formula":0,
		"mirror":0
		}
	for template in templates:
		builder_templates[template["type"]].append(template)
	set_up_template_select()
		#amounts[template["type"]].text = str(builder_templates[template["type"]].size())

func set_up_template_select():
	builder_templates_sorted = {
		"order":0,
		"blueprint":0,
		"scroll":0,
		"formula":0,
		"mirror":0
	}
	for item in template_select.get_children():
		template_select.remove_child(item)
		item.queue_free()
	var all_start_colors_false = true
	var all_end_colors_false = true
	for color_key in start_color_dict:
		if start_color_dict[color_key] == true:
			all_start_colors_false = false
	for color_key in end_color_dict:
		if end_color_dict[color_key] == true:
			all_end_colors_false = false
	for template_type in builder_templates:
		for template in builder_templates[template_type]:
			#print(template)
			if rarity_dict[template["rarity"]] and \
			(all_start_colors_false || start_color_dict[str(template["start_color"])]) and \
			(all_end_colors_false || end_color_dict[str(template["end_color"])]):
				builder_templates_sorted[template_type] += 1
		amounts[template_type].text = str(builder_templates_sorted[template_type])
	if template_type_selected == "" or rarity_dict == {"common":false,"uncommon":false,"rare":false,"epic":false,"legendary":false}:
		return
	for template in builder_templates[template_type_selected]:
		if rarity_dict[template["rarity"]] and \
		(all_start_colors_false || start_color_dict[str(template["start_color"])]) and \
		(all_end_colors_false || end_color_dict[str(template["end_color"])]):
			#print(template)
			var new_template_button = TEMPLATE_BUTTON.instantiate()
			template_select.add_child(new_template_button)
			new_template_button.template_id = template["id"]
			new_template_button.template_type = template["type"]
			new_template_button.template_name.text = template["name"]
			new_template_button.template_amount.text = infinity_symbol if template["always_available"] else "X"+str(int(template["available"]))
			if template["start_color"]:
				new_template_button.start_color_bonus_square.bonus_color.color = stats.COLOR_KEY[template["start_color"]]
				new_template_button.start_color_bonus_square.bonus_label.text = ""
				new_template_button.start_color = template["start_color"]
			else:
				new_template_button.start_label_2.show()
				new_template_button.start_color_bonus_square.hide()
			if template["end_color"]:
				new_template_button.end_color_bonus_square.bonus_color.color = stats.COLOR_KEY[template["end_color"]]
				new_template_button.end_color_bonus_square.bonus_label.text = ""
				new_template_button.end_color = template["end_color"]
			else:
				new_template_button.end_label_2.show()
				new_template_button.end_color_bonus_square.hide()
			new_template_button.template_shape_grid.create_template_shapes(template["component_grid"])
			new_template_button.connect("template_selected",template_button_pressed)

func template_button_pressed(template_id,template_type,start_color,end_color):
	#print("Pressed : ",id)
	template_selected.emit(template_id,template_type,start_color,end_color)

func _on_common_button_toggled(toggled_on: bool) -> void:
	rarity_dict["common"] = toggled_on
	set_up_template_select()

func _on_uncommon_button_toggled(toggled_on: bool) -> void:
	rarity_dict["uncommon"] = toggled_on
	set_up_template_select()

func _on_rare_button_toggled(toggled_on: bool) -> void:
	rarity_dict["rare"] = toggled_on
	set_up_template_select()

func _on_epic_button_toggled(toggled_on: bool) -> void:
	rarity_dict["epic"] = toggled_on
	set_up_template_select()

func _on_legendary_button_toggled(toggled_on: bool) -> void:
	rarity_dict["legendary"] = toggled_on
	set_up_template_select()

func _on_unit_select_button_pressed() -> void:
	template_type_selected = "order"
	set_up_template_select()

func _on_blueprint_select_button_pressed() -> void:
	template_type_selected = "blueprint"
	set_up_template_select()

func _on_scroll_select_button_pressed() -> void:
	template_type_selected = "scroll"
	set_up_template_select()

func _on_formula_select_button_pressed() -> void:
	template_type_selected = "formula"
	set_up_template_select()

func _on_mirror_select_button_pressed() -> void:
	template_type_selected = "mirror"
	set_up_template_select()

func _on_start_null_button_toggled(toggled_on: bool) -> void:
	start_color_dict["<null>"] = toggled_on
	set_up_template_select()

func _on_start_red_button_toggled(toggled_on: bool) -> void:
	start_color_dict["r"] = toggled_on
	set_up_template_select()

func _on_start_orange_button_toggled(toggled_on: bool) -> void:
	start_color_dict["o"] = toggled_on
	set_up_template_select()

func _on_start_yellow_button_toggled(toggled_on: bool) -> void:
	start_color_dict["y"] = toggled_on
	set_up_template_select()

func _on_start_green_button_toggled(toggled_on: bool) -> void:
	start_color_dict["g"] = toggled_on
	set_up_template_select()

func _on_start_blue_button_toggled(toggled_on: bool) -> void:
	start_color_dict["u"] = toggled_on
	set_up_template_select()

func _on_start_purple_button_toggled(toggled_on: bool) -> void:
	start_color_dict["p"] = toggled_on
	set_up_template_select()

func _on_start_white_button_toggled(toggled_on: bool) -> void:
	start_color_dict["w"] = toggled_on
	set_up_template_select()

func _on_start_black_button_toggled(toggled_on: bool) -> void:
	start_color_dict["b"] = toggled_on
	set_up_template_select()

func _on_start_all_button_toggled(toggled_on: bool) -> void:
	for button in start_color_buttons:
		button.button_pressed = toggled_on

func _on_end_null_button_toggled(toggled_on: bool) -> void:
	end_color_dict["<null>"] = toggled_on
	set_up_template_select()

func _on_end_red_button_toggled(toggled_on: bool) -> void:
	end_color_dict["r"] = toggled_on
	set_up_template_select()

func _on_end_orange_button_toggled(toggled_on: bool) -> void:
	end_color_dict["o"] = toggled_on
	set_up_template_select()

func _on_end_yellow_button_toggled(toggled_on: bool) -> void:
	end_color_dict["y"] = toggled_on
	set_up_template_select()

func _on_end_green_button_toggled(toggled_on: bool) -> void:
	end_color_dict["g"] = toggled_on
	set_up_template_select()

func _on_end_blue_button_toggled(toggled_on: bool) -> void:
	end_color_dict["u"] = toggled_on
	set_up_template_select()

func _on_end_purple_button_toggled(toggled_on: bool) -> void:
	end_color_dict["p"] = toggled_on
	set_up_template_select()

func _on_end_white_button_toggled(toggled_on: bool) -> void:
	end_color_dict["w"] = toggled_on
	set_up_template_select()

func _on_end_black_button_toggled(toggled_on: bool) -> void:
	end_color_dict["b"] = toggled_on
	set_up_template_select()

func _on_end_all_button_toggled(toggled_on: bool) -> void:
	for button in end_color_buttons:
		button.button_pressed = toggled_on
