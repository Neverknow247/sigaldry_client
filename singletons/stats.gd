extends Node

var background_color = Color("#464c54")
var color_one = Color("#cd5f2a")
var color_two = Color("#f2ab37")

var dev_mode = true
var rng = RandomNumberGenerator.new()
var transition_time = .15

const COLOR_KEY = {
	"R" : "FF0000",
	#"O" : "FFA500",
	"O" : "FF7F00",
	"Y" : "FFFF00",
	"G" : "00FF00",
	"U" : "0000FF",
	"P" : "800080",
	"W" : "FFFFFF",
	"B" : "000000",
	"C" : "909090"
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
