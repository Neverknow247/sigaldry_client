extends Control

var stats = Stats

@onready var transition = $transition
@onready var background_color = $background_color

var next_board = "res://client/client.tscn"

func _ready():
	background_color.color = stats.background_color
	RenderingServer.set_default_clear_color(Color.BLACK)
	await get_tree().create_timer(1.2).timeout
	start()

func start():
	if await SaveAndLoad.load_data():
		stats["save_data"]["stats"]["power_on_count"] += 1
	await SaveAndLoad.save_all()
	finish()

func finish():
	transition.fade_out()
	await get_tree().create_timer(stats.transition_time).timeout
	get_tree().change_scene_to_file(next_board)
