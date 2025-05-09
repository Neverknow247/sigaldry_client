extends Button

signal component_selected(_id)

@onready var modifier_label = $v_box_container/modifier_label
@onready var button_label = $v_box_container/button_label
@onready var color_profile_square = $color_profile_square
@onready var component_shape_grid = $component_shape_grid
@onready var amount_label = $amount_label
@onready var cost_label = $cost_icon/cost_label

var component_name = ""
var component_color = ""

var component_id : int

func _on_pressed():
	component_selected.emit(component_id)
