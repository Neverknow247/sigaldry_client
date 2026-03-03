extends Control

var scene_name = "card_image_edit"

var stats = Stats
var KEYWORD_GLOSS = KeyWordGlossary

signal back_to_editor
signal imagegen_make_image(_data,_card_subtype)
signal imagegen_get_unit_options(_data)

@onready var background_color: ColorRect = $background_color
@onready var card_preview: Control = $card_preview
@onready var submit_button: Button = $buttons_container/submit_button

@onready var unit_select_boxes: VBoxContainer = $unit_select_boxes
@onready var species_button: OptionButton = $unit_select_boxes/standard_select_box/species_button
@onready var class_button: OptionButton = $unit_select_boxes/standard_select_box/class_button
@onready var region_button: OptionButton = $unit_select_boxes/standard_select_box/region_button
@onready var get_unit_options_button: Button = $unit_select_boxes/get_unit_options_button
@onready var extra_species_button: OptionButton = $unit_select_boxes/premium_select_box_1/extra_species_button
@onready var style_button: OptionButton = $unit_select_boxes/premium_select_box_2/style_button
@onready var age_button: OptionButton = $unit_select_boxes/premium_select_box_2/age_button
@onready var shade_button: OptionButton = $unit_select_boxes/premium_select_box_2/shade_button
@onready var action_button: OptionButton = $unit_select_boxes/premium_select_box_3/action_button
@onready var scene_button: OptionButton = $unit_select_boxes/premium_select_box_3/scene_button
@onready var day_phase_button: OptionButton = $unit_select_boxes/premium_select_box_4/day_phase_button
@onready var weather_button: OptionButton = $unit_select_boxes/premium_select_box_4/weather_button

var first_unit_option_button_array = []
var second_unit_option_button_array = []

var class_status = "required"

var card_id = null
var card_subtype = null
var selected_unit_options = {
	"species" : null,
	"class" : null,
	"region" : null,
	"extra_species" : null,
	"action" : null,
	"age" : null,
	"day_phase" : null,
	"style" : null,
	"scene" : null,
	"shade" : null,
	"weather" : null
}
var selected_spell_options = {
	"effect" : null,
	"element" : null,
	"region" : null,
}
var dictionaries = {
	"species" : {},
	"class" : {},
	"region" : {},
	"extra_species" : {},
	"action" : {},
	"age" : {},
	"day_phase" : {},
	"style" : {},
	"scene" : {},
	"shade" : {},
	"weather" : {},
	"role" : {},
	"effect" : {},
	"element" : {},
}

func get_info_card_image_edit(payload):
	show()
	card_preview.show()
	card_preview.add_details(payload["def"])

func _ready():
	first_unit_option_button_array = [species_button,class_button,region_button,
	extra_species_button]
	second_unit_option_button_array = [style_button,age_button,shade_button,
	action_button,scene_button,day_phase_button,weather_button]
	first_spell_option_button_array = [role_button,effect_button,element_button,spell_region_button]
	second_spell_option_button_array = []
	background_color.color = stats.background_color
	for button in first_unit_option_button_array:
		button.get_popup().max_size.y = 800
	for button in second_unit_option_button_array:
		button.get_popup().max_size.y = 800
	for button in first_spell_option_button_array:
		button.get_popup().max_size.y = 800
	for button in second_spell_option_button_array:
		button.get_popup().max_size.y = 800
	full_reset()

func full_reset():
	card_subtype = null
	unit_select_boxes.hide()
	spell_select_boxes.hide()
	submit_button.disabled = true
	card_id = null
	for dictionary in dictionaries:
		dictionaries[dictionary] = {}
	full_reset_unit()
	full_reset_spell()

func full_reset_unit():
	class_button.disabled = true
	extra_species_button.disabled = true
	get_unit_options_button.disabled = true
	for button in first_unit_option_button_array:
		button.clear()
	for button in second_unit_option_button_array:
		button.clear()
		button.disabled = true
	species_button.add_item("Select A Species")
	class_button.add_item("Select A Class")
	region_button.add_item("Select A Region")
	extra_species_button.add_item("Select A Species")
	action_button.add_item("Select An Action")
	age_button.add_item("Select An Age")
	day_phase_button.add_item("Select A Day Phase")
	style_button.add_item("Select A Style")
	scene_button.add_item("Select A Scene")
	shade_button.add_item("Select A Shade")
	weather_button.add_item("Select The Weather")
	for option in selected_unit_options:
		selected_unit_options[option] = null

func reset_unit_options():
	for button in second_unit_option_button_array:
		button.clear()
		button.disabled = true
	action_button.add_item("Select An Action")
	age_button.add_item("Select An Age")
	day_phase_button.add_item("Select A Day Phase")
	style_button.add_item("Select A Style")
	scene_button.add_item("Select A Scene")
	shade_button.add_item("Select A Shade")
	weather_button.add_item("Select The Weather")
	for option in selected_unit_options:
		if option == "species" || option == "class" || \
		option == "region" || option == "extra_species":
			continue
		selected_unit_options[option] = null
	for dictionary in dictionaries:
		if dictionary == "species" || dictionary == "class" || \
		dictionary == "region" || dictionary == "extra_species":
			continue
		dictionaries[dictionary] = {}

var unit_image_gen_out = {"card_id":card_id}
func set_up_unit_image_gen_out():
	unit_image_gen_out = {"card_id":card_id}
	for selected in selected_unit_options:
		if selected_unit_options[selected]:
			unit_image_gen_out[selected] = selected_unit_options[selected]

var spell_image_gen_out = {"card_id":card_id}
func set_up_spell_image_gen_out():
	spell_image_gen_out = {"card_id":card_id}
	for selected in selected_spell_options:
		if selected_spell_options[selected]:
			spell_image_gen_out[selected] = selected_spell_options[selected]

func _on_back_button_pressed() -> void:
	back_to_editor.emit()
	full_reset()

func set_unit_requirements(payload):
	full_reset()
	show()
	card_subtype = "unit"
	unit_select_boxes.show()
	card_id = payload["card_id"]
	var i = 0
	for option in payload["species"]:
		#print(_species)
		i+=1
		dictionaries["species"][i] = option
		dictionaries["extra_species"][i] = option
		species_button.add_item(option["name"],i)
		extra_species_button.add_item(option["name"],i)
	i = 0
	for option in payload["classes"]:
		#print(_class)
		i+=1
		dictionaries["class"][i] = option
		class_button.add_item(option["name"],i)
	i = 0
	for option in payload["regions"]:
		print(option["description"])
		i+=1
		dictionaries["region"][i] = option
		region_button.add_item(option["name"],i)
		region_button.set_item_tooltip(i,option["description"])
	i = 0


func set_unit_options(payload):
	var i = 0
	for option in payload["actions"]:
		action_button.disabled = false
		i+=1
		dictionaries["action"][i] = option
		action_button.add_item(option["name"],i)
	i = 0
	for option in payload["ages"]:
		age_button.disabled = false
		i+=1
		dictionaries["age"][i] = option
		age_button.add_item(option["name"],i)
	i = 0
	for option in payload["day_phases"]:
		day_phase_button.disabled = false
		i+=1
		dictionaries["day_phase"][i] = option
		day_phase_button.add_item(option["name"],i)
	i = 0
	for option in payload["styles"]:
		style_button.disabled = false
		i+=1
		dictionaries["style"][i] = option
		style_button.add_item(option["name"],i)
	i = 0
	for option in payload["scenes"]:
		scene_button.disabled = false
		i+=1
		dictionaries["scene"][i] = option
		scene_button.add_item(option["name"],i)
	i = 0
	for option in payload["shades"]:
		shade_button.disabled = false
		i+=1
		dictionaries["shade"][i] = option
		shade_button.add_item(option["name"],i)
	i = 0
	for option in payload["weather"]:
		weather_button.disabled = false
		i+=1
		dictionaries["weather"][i] = option
		weather_button.add_item(option["name"],i)
	i = 0

func _on_species_button_item_selected(index: int) -> void:
	reset_extra_species()
	undo_class_select()
	reset_unit_options()
	if index == -1 || index == 0:
		selected_unit_options["species"] = null
	elif index > 0:
		selected_unit_options["species"] = dictionaries["species"][index]["id"]
		extra_species_button.disabled = false
		check_class_option(index)
		set_up_extra_species()
	check_unit_submit()
	set_up_unit_image_gen_out()

func _on_class_button_item_selected(index: int) -> void:
	reset_unit_options()
	if index == -1 || index == 0:
		selected_unit_options["class"] = null
	elif index > 0:
		selected_unit_options["class"] = dictionaries["class"][index]["id"]
	check_unit_submit()
	set_up_unit_image_gen_out()

func _on_region_button_item_selected(index: int) -> void:
	reset_unit_options()
	if index == -1 || index == 0:
		selected_unit_options["region"] = null
	elif index > 0:
		selected_unit_options["region"] = dictionaries["region"][index]["id"]
	check_unit_submit()
	set_up_unit_image_gen_out()

func check_class_option(_index):
	match dictionaries["species"][_index]["class_status"]:
		"required":
			class_status = "required"
			class_button.disabled = false
		"prohibited":
			class_status = "prohibited"
			class_button.disabled = true
		"optional":
			class_status = "optional"
			class_button.disabled = false

func undo_class_select():
	class_status = "required"
	selected_unit_options["class"] = null
	class_button.selected = 0
	class_button.disabled = true

func reset_extra_species():
	extra_species_button.disabled = true
	selected_unit_options["extra_species"] = null
	dictionaries["extra_species"] = dictionaries["species"]

func set_up_extra_species():
	dictionaries["extra_species"] = {}
	extra_species_button.clear()
	extra_species_button.add_item("Select A Species")
	var i = 0
	for species in dictionaries["species"]:
		if selected_unit_options["species"] != dictionaries["species"][species]["id"]:
			i+=1
			dictionaries["extra_species"][i] = dictionaries["species"][species]
			extra_species_button.add_item(dictionaries["species"][species]["name"],i)

func _on_extra_species_button_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_unit_options["extra_species"] = null
	elif index > 0:
		selected_unit_options["extra_species"] = dictionaries["extra_species"][index]["id"]
	set_up_unit_image_gen_out()

func _on_style_button_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_unit_options["style"] = null
	elif index > 0:
		selected_unit_options["style"] = dictionaries["style"][index]["id"]
	set_up_unit_image_gen_out()

func _on_age_button_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_unit_options["age"] = null
	elif index > 0:
		selected_unit_options["age"] = dictionaries["age"][index]["id"]
	set_up_unit_image_gen_out()

func _on_shade_button_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_unit_options["shade"] = null
	elif index > 0:
		selected_unit_options["shade"] = dictionaries["shade"][index]["id"]
	set_up_unit_image_gen_out()

func _on_action_button_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_unit_options["action"] = null
	elif index > 0:
		selected_unit_options["action"] = dictionaries["action"][index]["id"]
	set_up_unit_image_gen_out()

func _on_scene_button_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_unit_options["scene"] = null
	elif index > 0:
		selected_unit_options["scene"] = dictionaries["scene"][index]["id"]
	set_up_unit_image_gen_out()

func _on_day_phase_button_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_unit_options["day_phase"] = null
	elif index > 0:
		selected_unit_options["day_phase"] = dictionaries["day_phase"][index]["id"]
	set_up_unit_image_gen_out()

func _on_weather_button_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_unit_options["weather"] = null
	elif index > 0:
		selected_unit_options["weather"] = dictionaries["weather"][index]["id"]
	set_up_unit_image_gen_out()

func _on_get_unit_options_button_pressed() -> void:
	reset_unit_options()
	imagegen_get_unit_options.emit(unit_image_gen_out)

#SPELL SECTION
@onready var spell_select_boxes: VBoxContainer = $spell_select_boxes
@onready var role_button: OptionButton = $spell_select_boxes/role_and_effects_box/role_button
@onready var effect_button: OptionButton = $spell_select_boxes/role_and_effects_box/effect_button
@onready var element_button: OptionButton = $spell_select_boxes/standard_select_box/element_button
@onready var spell_region_button: OptionButton = $spell_select_boxes/standard_select_box/spell_region_button

var first_spell_option_button_array = []
var second_spell_option_button_array = []

func full_reset_spell():
	effect_button.disabled = true
	for button in first_spell_option_button_array:
		button.clear()
	for button in second_spell_option_button_array:
		button.clear()
		button.disabled = true
	role_button.add_item("Select A Role")
	element_button.add_item("Select An Element")
	spell_region_button.add_item("Select A Region")
	for option in selected_spell_options:
		selected_spell_options[option] = null

func set_spell_requirements(payload):
	#print(JSON.stringify(payload,"\t"))
	#for i in payload:
		#print(i)
	full_reset()
	show()
	card_subtype = "spell"
	spell_select_boxes.show()
	card_id = payload["card_id"]
	var i = 0
	var y = 0
	for option in payload["roles"]:
		i+=1
		y = 0
		dictionaries["role"][i] = option
		role_button.add_item(option["name"],i)
		dictionaries["effect"][option["name"]] = {}
		for effect in option["effects"]:
			#print(effect)
			y+=1
			dictionaries["effect"][option["name"]][y] = effect
	i = 0
	for option in payload["elements"]:
		#print(option)
		i+=1
		dictionaries["element"][i] = option
		element_button.add_item(option["name"],i)
	i = 0
	for option in payload["regions"]:
		#print(option)
		i+=1
		dictionaries["region"][i] = option
		spell_region_button.add_item(option["name"],i)
		spell_region_button.set_item_tooltip(i,option["description"])
	i = 0

var selected_role = null
func _on_role_button_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		undo_spell_effect_select()
		selected_role = null
		#selected_spell_options["effect"] = null
	elif index > 0:
		selected_role = dictionaries["role"][index]["name"]
		reset_spell_effect_select()

func _on_effect_button_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_spell_options["effect"] = null
	elif index > 0:
		selected_spell_options["effect"] = dictionaries["effect"][selected_role][index]["id"]
	check_spell_submit()
	set_up_spell_image_gen_out()

func _on_element_button_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_spell_options["element"] = null
	elif index > 0:
		selected_spell_options["element"] = dictionaries["element"][index]["id"]
	check_spell_submit()
	set_up_spell_image_gen_out()

func _on_spell_region_button_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_spell_options["region"] = null
	elif index > 0:
		selected_spell_options["region"] = dictionaries["region"][index]["id"]
	check_spell_submit()
	set_up_spell_image_gen_out()

func undo_spell_effect_select():
	effect_button.disabled = true

func reset_spell_effect_select():
	effect_button.clear()
	effect_button.add_item("Select An Effect")
	if !selected_role:
		return
	else:
		var i = 0
		for effect in dictionaries["effect"][selected_role]:
			i+=1
			effect_button.add_item(dictionaries["effect"][selected_role][effect]["name"],i)
	effect_button.disabled = false

func check_unit_submit():
	if card_id != null and \
	selected_unit_options["species"] != null and \
	selected_unit_options["region"] != null and \
	((selected_unit_options["class"] != null and class_status == "required") ||\
	(selected_unit_options["class"] == null and class_status == "prohibited") ||\
	class_status == "optional"):
		submit_button.disabled = false
		get_unit_options_button.disabled = false
	else:
		submit_button.disabled = true
		get_unit_options_button.disabled = true

func check_spell_submit():
	if card_id != null and \
	selected_spell_options["effect"] != null and \
	selected_spell_options["element"] != null and \
	selected_spell_options["region"] != null:
		submit_button.disabled = false
	else:
		submit_button.disabled = true

func _on_submit_button_pressed() -> void:
	match card_subtype:
		"unit":
			imagegen_make_image.emit(unit_image_gen_out,card_subtype)
		"spell":
			imagegen_make_image.emit(spell_image_gen_out,card_subtype)
		_:
			pass
	#print(image_gen_out)
	#return
	_on_back_button_pressed()
