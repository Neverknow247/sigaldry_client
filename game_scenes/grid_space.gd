extends CenterContainer

@onready var control = $Control/Control
@onready var card = $Control/Control/card_preview

var tile_id = ""

signal tile_chosen(id)

func _ready():
	control.scale = Vector2(.6,.6)

func _on_grid_button_pressed():
	tile_chosen.emit(tile_id)
