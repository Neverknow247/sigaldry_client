extends Button

@onready var category_label: Label = $margin_container/v_box_container/category_label
@onready var category_icon: TextureRect = $margin_container/v_box_container/category_icon

var category_id

signal category_selected(_category_id)

func _on_pressed() -> void:
	category_selected.emit(category_id)
