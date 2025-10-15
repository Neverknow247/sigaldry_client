extends Button

@onready var template_amount: Label = $template_amount
@onready var template_name: Label = $template_name
@onready var template_shape_grid: Control = $template_shape_grid
@onready var start_label_2: Label = $color_bonus_container/start_bonus_container/start_label_2
@onready var end_label_2: Label = $color_bonus_container/end_bonus_container/end_label_2
@onready var start_color_bonus_square: ColorRect = $color_bonus_container/start_bonus_container/start_color_bonus_square
@onready var end_color_bonus_square: ColorRect = $color_bonus_container/end_bonus_container/end_color_bonus_square

signal template_selected(_id)

var template_id : int
var template_type : String

func _on_pressed():
	template_selected.emit(template_id,template_type)
