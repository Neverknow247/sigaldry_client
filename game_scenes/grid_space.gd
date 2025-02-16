extends CenterContainer

@onready var control = $Control/Control
@onready var card = $Control/Control/card_preview

var tile_id = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	control.scale = Vector2(.6,.6)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

signal set_tile_id(id)
func _on_button_pressed():
	set_tile_id.emit(tile_id)
