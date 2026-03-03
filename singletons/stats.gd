extends Node

var logged_in_user = ""
var game_type = ""

var background_color = Color("#464c54")
var color_one = Color("#cd5f2a")
var color_two = Color("#f2ab37")

var dev_mode = true
#var dev_mode = false
var rng = RandomNumberGenerator.new()
var transition_time = .20
#var transition_time = .15

const COLOR_KEY = {
	"r" : "FF0000",
	"o" : "FF7F00",
	"y" : "FFFF00",
	"g" : "00FF00",
	"u" : "0000FF",
	"p" : "800080",
	"w" : "FFFFFF",
	"b" : "000000",
	"a" : "909090",
	"n" : "65330D",
	"k" : "FF90Fa",
}

const COLOR_NAMES = {
	"r" : "Red",
	"o" : "Orange",
	"y" : "Yellow",
	"g" : "Green",
	"u" : "Blue",
	"p" : "Purple",
	"w" : "White",
	"b" : "Black",
	"a" : "Gray",
	"n" : "Brown",
	"k" : "Pink"
}

var new_save_data = {
	"version" : ProjectSettings.get_setting("application/config/version"),
	"remember_me" : {
		"username" : "",
		"password" : "",
	},
	"stats" : {
		"power_on_count" : 0,
	},
}

var save_data = return_new_save_data()

func return_new_save_data():
	return new_save_data.duplicate(true)

func delete_save():
	save_data = return_new_save_data()


#SETUP SYSTEM
func setup_player(payload):
	var client_settings = payload["client_settings"]
	if client_settings.has("pve_xp"):
		pve_xp = client_settings["pve_xp"]
	else:
		pve_xp = 17.5
		pve_level = 0
		client_settings["pve_xp"] = 17.5
	if client_settings.has("pvp_xp"):
		pvp_xp = client_settings["pvp_xp"]
	else:
		pvp_xp = 17.5
		pvp_level = 0
		client_settings["pvp_xp"] = 17.5


#XP SYSTEM
signal stats_modified(data)

var pve_xp = 17.5:
	get:
		return pve_xp
	set(value):
		value = max(17.5,value)
		if value < pve_xp:
			pve_level = 0
		pve_xp = value
		pve_gained_xp(value)
		stats_modified.emit({
			"stat" : "pve_xp",
			"value" : value
		})

var pve_level = 0:
	get:
		return pve_level
	set(value):
		pve_level = value
		stats_modified.emit({
			"stat" : "pve_level",
			"value" : value
		})

func pve_gained_xp(xp_value):
	var next_level_xp = 0
	var previous_level_xp = 0
	var level_up_modifier = 17.5
	var level_up_percentage =  1.1309
	var next_level_xp_needed = level_up_modifier * level_up_percentage ** pve_level
	next_level_xp = next_level_xp_needed
	if xp_value > next_level_xp_needed:
		previous_level_xp = next_level_xp_needed
		pve_level_up()
		pve_gained_xp(xp_value)

func pve_level_up():
	pve_level += 1


var pvp_xp = 17.5:
	get:
		return pvp_xp
	set(value):
		value = max(17.5,value)
		if value < pvp_xp:
			pvp_level = 0
		pvp_xp = value
		pvp_gained_xp(value)
		stats_modified.emit({
			"stat" : "pvp_xp",
			"value" : value
		})

var pvp_level = 0:
	get:
		return pvp_level
	set(value):
		pvp_level = value
		stats_modified.emit({
			"stat" : "pvp_level",
			"value" : value
		})

func pvp_gained_xp(xp_value):
	var next_level_xp = 0
	var previous_level_xp = 0
	var level_up_modifier = 17.5
	var level_up_percentage =  1.1309
	var next_level_xp_needed = level_up_modifier * level_up_percentage ** pvp_level
	next_level_xp = next_level_xp_needed
	if xp_value > next_level_xp_needed:
		previous_level_xp = next_level_xp_needed
		pvp_level_up()
		pvp_gained_xp(xp_value)

func pvp_level_up():
	pvp_level += 1
