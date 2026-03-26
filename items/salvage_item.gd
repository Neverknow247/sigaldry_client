extends Control

@onready var item_label: Label = $margin_container/h_box_container/item_label
@onready var spin_box: SpinBox = $margin_container/h_box_container/spin_box
@onready var amount_label: Label = $margin_container/h_box_container/amount_label

var item_id

signal value_changed(_item_id,_value)

func _on_spin_box_value_changed(value: float) -> void:
	value_changed.emit(item_id,value)
