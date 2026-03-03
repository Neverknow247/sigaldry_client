extends Control
var scene_name = "game_select"

var stats = Stats

const REWARD_BUTTON = preload("res://items/reward_button.tscn")
const REWARD_LABEL = preload("res://items/reward_label.tscn")

@onready var color_background: ColorRect = $color_background
@onready var color_background_2: ColorRect = $game_type_select/color_background
@onready var game_type_select: Control = $game_type_select

@onready var rarity_col: VBoxContainer = $margin_container/v_box_container/h_box_container/rarity_col
@onready var deck_col: VBoxContainer = $margin_container/v_box_container/h_box_container/deck_col
@onready var region_col: VBoxContainer = $margin_container/v_box_container/h_box_container/region_col
@onready var pvp_timeout_col: VBoxContainer = $margin_container/v_box_container/h_box_container/pvp_timeout_col

@onready var min_rarity_option: OptionButton = $margin_container/v_box_container/h_box_container/rarity_col/min_rarity/min_rarity_option
@onready var max_rarity_option: OptionButton = $margin_container/v_box_container/h_box_container/rarity_col/max_rarity/max_rarity_option
@onready var deck_option: OptionButton = $margin_container/v_box_container/h_box_container/deck_col/deck_option
@onready var region_option: OptionButton = $margin_container/v_box_container/h_box_container/region_col/region_option
@onready var pvp_timeout_option: OptionButton = $margin_container/v_box_container/h_box_container/pvp_timeout_col/pvp_timeout_option

signal pve_game_options
signal pvp_game_options
signal look_for_game(_data)

var pvp_timeouts = [
	{
		"time" : 600,
		"name" : "10 Minutes"
	},
	{
		"time" : 300,
		"name" : "5 Minutes"
	},
	{
		"time" : 120,
		"name" : "2 Minutes"
	},
	{
		"time" : 60,
		"name" : "60 Seconds"
	},
	{
		"time" : 30,
		"name" : "30 Seconds"
	},
	{
		"time" : 15,
		"name" : "15 Seconds"
	},
]

var selected_game_options = {
	"match_type" : null,
	"min_rarity" : null,
	"max_rarity" : null,
	"pve_deck_id" : null,
	"region" : null,
}
var dictionaries = {
	"rarity" : {},
	"pve_deck_id" : {},
	"region" : {},
	"pvp_timeout" : {}
}

func _ready() -> void:
	color_background.color = stats.background_color
	color_background_2.color = stats.background_color

func reset():
	game_type_select.show()
	dictionaries = {
		"rarity" : {},
		"pve_deck_id" : {},
		"region" : {},
		"pvp_timeout" : {}
	}
	selected_game_options = {
		"match_type" : null,
		"min_rarity" : null,
		"max_rarity" : null,
		"pve_deck_id" : null,
		"region" : null,
		"pvp_timeout" : null
	}
	min_rarity_option.clear()
	max_rarity_option.clear()
	deck_option.clear()
	region_option.clear()
	pvp_timeout_option.clear()
	rarity_col.show()
	deck_col.show()
	region_col.show()
	pvp_timeout_col.show()

func set_up_pve(payload):
	reset()
	#turn_preference
	pvp_timeout_col.hide()
	selected_game_options["match_type"] = "pve"
	min_rarity_option.add_item("Same")
	max_rarity_option.add_item("Same")
	deck_option.add_item("Random")
	region_option.add_item("Random")
	var i = 0
	for rarity in payload["rarities"]:
		i+=1
		dictionaries["rarity"][i] = rarity
		min_rarity_option.add_item(rarity["name"],i)
		max_rarity_option.add_item(rarity["name"],i)
	i = 0
	for deck in payload["pve_opponent_decks"]:
		i+=1
		dictionaries["pve_deck_id"][i] = deck
		deck_option.add_item(deck["name"],i)
	i = 0
	for region in payload["regions"]:
		i+=1
		dictionaries["region"][i] = region
		region_option.add_item(region["name"],i)
	i = 0
	set_up_looking_for_game()
	game_type_select.hide()

func set_up_pvp(payload):
	reset()
	deck_col.hide()
	selected_game_options["match_type"] = "pvp"
	min_rarity_option.add_item("Same")
	max_rarity_option.add_item("Same")
	region_option.add_item("Random")
	pvp_timeout_option.add_item("Never")
	var i = 0
	for rarity in payload["rarities"]:
		i+=1
		dictionaries["rarity"][i] = rarity
		min_rarity_option.add_item(rarity["name"],i)
		max_rarity_option.add_item(rarity["name"],i)
	i = 0
	for region in payload["regions"]:
		i+=1
		dictionaries["region"][i] = region
		region_option.add_item(region["name"],i)
	i = 0
	for timeout in pvp_timeouts:
		i+=1
		dictionaries["pvp_timeout"][i] = timeout
		pvp_timeout_option.add_item(timeout["name"],i)
	set_up_looking_for_game()
	game_type_select.hide()

func _on_story_button_pressed() -> void:
	pass # Replace with function body.

func _on_pve_button_pressed() -> void:
	pve_game_options.emit()

func _on_pvp_button_pressed() -> void:
	pvp_game_options.emit()

var looking_for_game_out = {}
func set_up_looking_for_game():
	looking_for_game_out = {}
	for selected in selected_game_options:
		if selected_game_options[selected]:
			looking_for_game_out[selected] = selected_game_options[selected]

func _on_look_for_game_button_pressed() -> void:
	print(looking_for_game_out)
	look_for_game.emit(looking_for_game_out)

func _on_min_rarity_option_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_game_options["min_rarity"] = null
	elif index > 0:
		selected_game_options["min_rarity"] = dictionaries["rarity"][index]["value"]
	set_up_looking_for_game()

func _on_max_rarity_option_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_game_options["max_rarity"] = null
	elif index > 0:
		selected_game_options["max_rarity"] = dictionaries["rarity"][index]["value"]
	set_up_looking_for_game()

func _on_deck_option_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_game_options["pve_deck_id"] = null
	elif index > 0:
		selected_game_options["pve_deck_id"] = dictionaries["pve_deck_id"][index]["id"]
	set_up_looking_for_game()

func _on_region_option_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_game_options["region"] = null
	elif index > 0:
		selected_game_options["region"] = dictionaries["region"][index]["id"]
	set_up_looking_for_game()

func _on_pvp_timeout_option_item_selected(index: int) -> void:
	if index == -1 || index == 0:
		selected_game_options["pvp_timeout"] = null
	elif index > 0:
		selected_game_options["pvp_timeout"] = dictionaries["pvp_timeout"][index]["time"]
	set_up_looking_for_game()
