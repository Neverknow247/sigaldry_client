extends Control

var stats = Stats

const TEMPLATE_BUTTON = preload("res://card_builder_scenes/template_button.tscn")

@onready var template_select: VBoxContainer = $h_box_container/scroll_container/template_select

var template_type_selected = ""
var start_color_selected = ""
var end_color_selected = ""
var builder_templates = {
	"order":[],
	"blueprint":[],
	"scroll":[],
	"formula":[],
	"mirrors":[]
}
var rarity_dict = {
	"common":true,
	"uncommon":true,
	"rare":true,
	"epic":true,
	"legendary":true
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

signal template_selected(template_id,template_type)

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
	for template in templates:
		builder_templates[template["type"]].append(template)

func set_up_template_select():
	for item in template_select.get_children():
		template_select.remove_child(item)
		item.queue_free()
	if template_type_selected == "" or rarity_dict == {"common":false,"uncommon":false,"rare":false,"epic":false,"legendary":false}:
		return
	for template in builder_templates[template_type_selected]:
		if rarity_dict[template["rarity"]] and \
		(start_color_selected == "" || start_color_selected == str(template["start_color"])) and \
		(end_color_selected == "" || end_color_selected == str(template["end_color"])):
			print(template)
			var new_template_button = TEMPLATE_BUTTON.instantiate()
			template_select.add_child(new_template_button)
			new_template_button.template_id = template["id"]
			new_template_button.template_type = template["type"]
			new_template_button.template_name.text = template["name"]
			new_template_button.template_amount.text = infinity_symbol if template["always_available"] else "X"+str(int(template["available"]))
			if template["start_color"]:
				new_template_button.start_color_bonus_square.bonus_color.color = stats.COLOR_KEY[template["start_color"]]
				new_template_button.start_color_bonus_square.bonus_label.text = ""
			else:
				new_template_button.start_label_2.show()
				new_template_button.start_color_bonus_square.hide()
			if template["end_color"]:
				new_template_button.end_color_bonus_square.bonus_color.color = stats.COLOR_KEY[template["end_color"]]
				new_template_button.end_color_bonus_square.bonus_label.text = ""
			else:
				new_template_button.end_label_2.show()
				new_template_button.end_color_bonus_square.hide()
			new_template_button.template_shape_grid.create_template_shapes(template["component_grid"])
			new_template_button.connect("template_selected",template_button_pressed)

func template_button_pressed(template_id,template_type):
	#print("Pressed : ",id)
	template_selected.emit(template_id,template_type)

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

func _on_start_color_button_item_selected(index: int) -> void:
	start_color_selected = color_index_dict[index]
	set_up_template_select()

func _on_end_color_button_item_selected(index: int) -> void:
	end_color_selected = color_index_dict[index]
	set_up_template_select()
