extends Control

@onready var window: Window = $window
@onready var tooltip_rich_text_label: RichTextLabel = $window/tooltip_rich_text_label

func _ready() -> void:
	return
	#RenderingServer.set_default_clear_color(Color.AQUA)

func set_up_text(text):
	tooltip_rich_text_label.text = text

func set_up_size():
	window.size= tooltip_rich_text_label.size

func _on_window_close_requested() -> void:
	queue_free()


func _on_tooltip_rich_text_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 2 and event.double_click == true:
		queue_free()
