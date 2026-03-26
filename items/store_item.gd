extends HBoxContainer

@onready var name_label: Label = $item_button/name_label
@onready var cost_label: Label = $item_button/h_box_container2/cost_label
@onready var spin_box: SpinBox = $spin_box

var item_key

signal item_selected(_item_key,_item_quantity)

func _on_item_button_pressed() -> void:
	item_selected.emit(item_key,spin_box.value)
