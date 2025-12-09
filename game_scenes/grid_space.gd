extends CenterContainer

#const BOARD_CARD = preload("res://assets/art/board_card.png")
#const BOARD_CARD_AVATAR = preload("res://assets/art/board_card_avatar.png")
const BOARD_CARD = preload("res://assets/art/card/test_unit.png")
const BOARD_CARD_AVATAR = preload("res://assets/art/card/test_unit.png")

@onready var control = $Control/Control
@onready var card = $Control/Control/card_preview
#@onready var card = $Control/Control/card
@onready var grid_button = $grid_button
@onready var grid_button_color = $grid_button/grid_button_color
@onready var game_effect_queue = $game_effect_queue

@export var default_color : Color = Color.BLACK
@export var friendly_color : Color = Color.BLACK
@export var unfriendly_color : Color = Color.BLACK
@export var move_color : Color = Color.BLACK

@onready var card_image: TextureRect = $Control/Control/card_image

@onready var trap = $Control/trap
@onready var trap_label = $Control/trap/trap_label

var tile_id = ""
var tile_type = ""
var occupied = false
var occupant_id = ""
var occupant_type = ""

var abilities = {}
var health = ""

signal tile_chosen(id)
signal get_info(data)

func _ready():
	return
	#control.scale = Vector2(.6,.6)

func set_avatar(value):
	if value:
		card.texture = BOARD_CARD_AVATAR
	else:
		card.texture = BOARD_CARD

func _on_grid_button_pressed():
	if occupied:
		tile_chosen.emit(occupant_id,occupant_type)
	else:
		tile_chosen.emit(tile_id,tile_type)

func disable_button(disable:bool):
	grid_button.disabled = disable
	grid_button_color.color = default_color

func edit_theme_graphic(_target):
	var target = _target
	if target["action"] == "move":
		grid_button_color.color = move_color
	elif target["action"] == "play" || target["action"] == "use":
		if target["disposition"] == "friendly":
			grid_button_color.color = friendly_color
		elif target["disposition"] == "unfriendly":
			grid_button_color.color = unfriendly_color

func _on_card_select_get_info():
	#print(occupant_type)
	get_info.emit({"type":occupant_type,"id":str(occupant_id)})
