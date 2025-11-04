extends Node

var background_color = Color("#464c54")
var color_one = Color("#cd5f2a")
var color_two = Color("#f2ab37")

var dev_mode = true
var rng = RandomNumberGenerator.new()
var transition_time = .20
#var transition_time = .15

const COLOR_KEY = {
	"r" : "FF0000",
	#"O" : "FFA500",
	"o" : "FF7F00",
	"y" : "FFFF00",
	"g" : "00FF00",
	"u" : "0000FF",
	"p" : "800080",
	"w" : "FFFFFF",
	"b" : "000000",
	"a" : "909090"
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
	"a" : "Gray"
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
