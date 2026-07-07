extends Popup

@onready var panel_container: PanelContainer = $panel_container
@onready var title_label: Label = $panel_container/margin_container/v_box_container/header_row/title_label
@onready var close_button: Button = $panel_container/margin_container/v_box_container/header_row/close_button
@onready var tooltip_rich_text_label: RichTextLabel = $panel_container/margin_container/v_box_container/tooltip_rich_text_label

var keyword_key: String = ""

func set_up_text(_keyword_key: String, title: String, text: String) -> void:
	keyword_key = _keyword_key
	title_label.text = title
	tooltip_rich_text_label.text = text

func popup_centered_on_screen(cascade_index: int = 0) -> void:
	await get_tree().process_frame
	var popup_size := panel_container.get_combined_minimum_size()
	var viewport_size := Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	var final_position := (viewport_size - popup_size) / 2.0
	final_position += Vector2(cascade_index, cascade_index) * 30.0
	final_position.x = clamp(final_position.x, 0, viewport_size.x - popup_size.x)
	final_position.y = clamp(final_position.y, 0, viewport_size.y - popup_size.y)
	popup(Rect2i(Vector2i(final_position), Vector2i(popup_size)))

func _on_close_button_pressed() -> void:
	hide()

func _on_popup_hide() -> void:
	if Utils.open_tooltips.get(keyword_key) == self:
		Utils.open_tooltips.erase(keyword_key)
	queue_free()
