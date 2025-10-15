extends Control

var scene_name = "card_image_edit"

var stats = Stats
var KEYWORD_GLOSS = KeyWordGlossary

signal back_to_editor
signal imagegen_make_unit_image(_data)
signal imagegen_get_unit_options(_data)

@onready var background_color: ColorRect = $background_color
@onready var card_preview: Control = $card_preview
@onready var race_button: OptionButton = $select_boxes/standard_select_box/race_button
@onready var class_button: OptionButton = $select_boxes/standard_select_box/class_button
@onready var region_button: OptionButton = $select_boxes/standard_select_box/region_button
@onready var extra_race_button: OptionButton = $select_boxes/premium_select_box_1/extra_race_button
@onready var style_button: OptionButton = $select_boxes/premium_select_box_2/style_button
@onready var age_button: OptionButton = $select_boxes/premium_select_box_2/age_button
@onready var shade_button: OptionButton = $select_boxes/premium_select_box_2/shade_button
@onready var action_button: OptionButton = $select_boxes/premium_select_box_3/action_button
@onready var scene_button: OptionButton = $select_boxes/premium_select_box_3/scene_button
@onready var day_phase_button: OptionButton = $select_boxes/premium_select_box_4/day_phase_button
@onready var weather_button: OptionButton = $select_boxes/premium_select_box_4/weather_button
@onready var submit_button: Button = $buttons_container/submit_button

var first_option_button_array = []
var second_option_button_array = []

var class_status = "required"

var card_id = null
var selected_race = null
var selected_extra_race = null
var selected_class = null
var selected_region = null
var selected_action = null
var selected_age = null
var selected_day_phase = null
var selected_style = null
var selected_scene = null
var selected_shade = null
var selected_weather = null
var race_dictionary = {}
var class_dictionary = {}
var region_dictionary = {}
var action_dictionary = {}
var age_dictionary = {}
var day_phase_dictionary = {}
var style_dictionary = {}
var scene_dictionary = {}
var shade_dictionary = {}
var weather_dictionary = {}

func _ready():
	first_option_button_array = [race_button,class_button,region_button,
	extra_race_button]
	second_option_button_array = [style_button,age_button,shade_button,
	action_button,scene_button,day_phase_button,weather_button]
	background_color.color = stats.background_color
	for button in first_option_button_array:
		button.get_popup().max_size.y = 800
	for button in second_option_button_array:
		button.get_popup().max_size.y = 800
	#race_button.get_popup().max_size.y = 800
	#class_button.get_popup().max_size.y = 800
	#region_button.get_popup().max_size.y = 800
	#extra_race_button.get_popup().max_size.y = 800
	reset()

func reset():
	for button in first_option_button_array:
		button.clear()
	submit_button.disabled = true
	card_id = null
	reset_race()
	reset_extra_race()
	reset_class()
	reset_region()
	reset_unit_options()

func reset_unit_options():
	for button in second_option_button_array:
		button.clear()
	selected_action = null
	action_dictionary = {}
	action_button.add_item("Select An Action")
	selected_age = null
	age_dictionary = {}
	age_button.add_item("Select An Age")
	selected_day_phase = null
	day_phase_dictionary = {}
	day_phase_button.add_item("Select A Day Phase")
	selected_style = null
	style_dictionary = {}
	style_button.add_item("Select A Style")
	selected_scene = null
	scene_dictionary = {}
	scene_button.add_item("Select A Scene")
	selected_shade = null
	shade_dictionary = {}
	shade_button.add_item("Select A Shade")
	selected_weather = null
	weather_dictionary = {}
	weather_button.add_item("Select The Weather")
	

func reset_race():
	selected_race = null
	#race_button.clear()
	race_dictionary = {}
	race_button.add_item("Select A Race")

func reset_extra_race():
	selected_extra_race = null
	#extra_race_button.clear()
	extra_race_button.add_item("Select A Race")

func reset_class():
	class_status = "required"
	selected_class = null
	#class_button.clear()
	class_dictionary = {}
	class_button.add_item("Select A Class")
	class_button.disabled = true

func reset_region():
	#selected_region = null
	#region_button.clear()
	region_dictionary = {}
	region_button.add_item("Select A Region")

func _on_back_button_pressed() -> void:
	back_to_editor.emit()
	reset()

func set_unit_requirements(payload):
	#for i in payload["regions"]:
		#print(i)
	card_id = payload["card_id"]
	var i = 0
	for option in payload["races"]:
		#print(_race)
		i+=1
		race_dictionary[i] = option
		race_button.add_item(option["name"],i)
		extra_race_button.add_item(option["name"],i)
	i = 0
	for option in payload["classes"]:
		#print(_class)
		i+=1
		class_dictionary[i] = option
		class_button.add_item(option["name"],i)
	i = 0
	for option in payload["regions"]:
		#print(_region)
		i+=1
		region_dictionary[i] = option
		region_button.add_item(option["name"],i)
		region_button.set_item_tooltip(i,option["description"])
	i = 0

func set_unit_options(payload):
	var i = 0
	for option in payload["actions"]:
		i+=1
		action_dictionary[i] = option
		action_button.add_item(option["name"],i)
	i = 0
	for option in payload["ages"]:
		i+=1
		age_dictionary[i] = option
		age_button.add_item(option["name"],i)
	i = 0
	for option in payload["day_phases"]:
		i+=1
		day_phase_dictionary[i] = option
		day_phase_button.add_item(option["name"],i)
	i = 0
	for option in payload["genders"]:
		i+=1
		style_dictionary[i] = option
		style_button.add_item(option["name"],i)
	i = 0
	for option in payload["scenes"]:
		i+=1
		scene_dictionary[i] = option
		scene_button.add_item(option["name"],i)
	i = 0
	for option in payload["skin_tones"]:
		i+=1
		shade_dictionary[i] = option
		shade_button.add_item(option["name"],i)
	i = 0
	for option in payload["weather"]:
		i+=1
		weather_dictionary[i] = option
		weather_button.add_item(option["name"],i)
	i = 0

func _on_race_button_item_selected(index: int) -> void:
	undo_class_select()
	if index == -1:
		selected_race = null
	elif index > 0:
		selected_race = race_dictionary[index]["id"]
		check_class_option(index)
	check_submit()

func _on_extra_race_button_item_selected(index: int) -> void:
	if index == -1:
		selected_extra_race = null
	elif index > 0:
		selected_extra_race = race_dictionary[index]["id"]

func undo_class_select():
	class_status = "required"
	selected_class = null
	class_button.selected = 0
	class_button.disabled = true

func check_class_option(_index):
	#print(race_dictionary[_index])
	if race_dictionary[_index]["class_status"] == "required":
		class_status = "required"
		class_button.disabled = false
	elif race_dictionary[_index]["class_status"] == "prohibited":
		class_status = "prohibited"
		class_button.disabled = true
	elif race_dictionary[_index]["class_status"] == "optional":
		class_status = "optional"
		class_button.disabled = false

func _on_class_button_item_selected(index: int) -> void:
	if index == -1:
		selected_class = null
	elif index > 0:
		selected_class = class_dictionary[index]["id"]
	check_submit()

func _on_region_button_item_selected(index: int) -> void:
	if index == -1:
		selected_region = null
	elif index > 0:
		selected_region = region_dictionary[index]["id"]
	check_submit()

func _on_style_button_item_selected(index: int) -> void:
	if index == -1:
		selected_style = null
	elif index > 0:
		selected_style = style_dictionary[index]["id"]

func _on_age_button_item_selected(index: int) -> void:
	if index == -1:
		selected_age = null
	elif index > 0:
		selected_age = age_dictionary[index]["id"]

func _on_shade_button_item_selected(index: int) -> void:
	if index == -1:
		selected_shade = null
	elif index > 0:
		selected_shade = shade_dictionary[index]["id"]

func _on_action_button_item_selected(index: int) -> void:
	if index == -1:
		selected_action = null
	elif index > 0:
		selected_action = action_dictionary[index]["id"]

func _on_scene_button_item_selected(index: int) -> void:
	if index == -1:
		selected_scene = null
	elif index > 0:
		selected_scene = scene_dictionary[index]["id"]

func _on_day_phase_button_item_selected(index: int) -> void:
	if index == -1:
		selected_day_phase = null
	elif index > 0:
		selected_day_phase = day_phase_dictionary[index]["id"]

func _on_weather_button_item_selected(index: int) -> void:
	if index == -1:
		selected_weather = null
	elif index > 0:
		selected_weather = weather_dictionary[index]["id"]

func check_submit():
	if card_id != null and selected_race != null and ((selected_class != null and class_status == "required") || (selected_class == null and class_status == "prohibited") || (class_status == "optional")) and selected_region != null:
		submit_button.disabled = false
	else:
		submit_button.disabled = true

func _on_submit_button_pressed() -> void:
	if card_id != null and selected_race != null and ((selected_class != null and class_status == "required") || (selected_class == null and class_status == "prohibited") || (class_status == "optional")) and selected_region != null:
		var query = build_query()
		imagegen_make_unit_image.emit(query)
		_on_back_button_pressed()

func build_query():
	var query = {"card_id":card_id,"race":selected_race,"class":selected_class,"region":selected_region}
	if selected_extra_race:
		query["extra_race"] = selected_extra_race
	if selected_action:
		query["action"] = selected_action
	if selected_age:
		query["age"] = selected_age
	if selected_day_phase:
		query["day_phase"] = selected_day_phase
	if selected_style:
		query["gender"] = selected_style
	if selected_scene:
		query["scene"] = selected_scene
	if selected_shade:
		query["skin_tone"] = selected_shade
	if selected_weather:
		query["weather"] = selected_weather
	return query

func get_info_card_image_edit(payload):
	#print(payload)
	show()
	card_preview.show()
	card_preview.add_details(payload["def"])

func _on_get_unit_options_button_pressed() -> void:
	reset_unit_options()
	imagegen_get_unit_options.emit({"card_id":card_id,"race":selected_race,"class":selected_class,"region":selected_region})
