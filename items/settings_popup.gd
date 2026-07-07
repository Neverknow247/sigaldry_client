extends Popup

@onready var master_slider: HSlider = $color_rect/center_container/v_box_container/master_row/master_slider
@onready var music_slider: HSlider = $color_rect/center_container/v_box_container/music_row/music_slider
@onready var voice_slider: HSlider = $color_rect/center_container/v_box_container/voice_row/voice_slider
@onready var sfx_slider: HSlider = $color_rect/center_container/v_box_container/sfx_row/sfx_slider

@onready var master_value_label: Label = $color_rect/center_container/v_box_container/master_row/master_value_label
@onready var music_value_label: Label = $color_rect/center_container/v_box_container/music_row/music_value_label
@onready var voice_value_label: Label = $color_rect/center_container/v_box_container/voice_row/voice_value_label
@onready var sfx_value_label: Label = $color_rect/center_container/v_box_container/sfx_row/sfx_value_label

func _ready() -> void:
	master_slider.value = Utils.volume_settings["master"]
	music_slider.value = Utils.volume_settings["music"]
	voice_slider.value = Utils.volume_settings["voice"]
	sfx_slider.value = Utils.volume_settings["sfx"]
	_update_value_label(master_value_label, master_slider.value)
	_update_value_label(music_value_label, music_slider.value)
	_update_value_label(voice_value_label, voice_slider.value)
	_update_value_label(sfx_value_label, sfx_slider.value)

func _update_value_label(label: Label, value: float) -> void:
	label.text = str(roundi(value * 100)) + "%"

func _on_master_slider_value_changed(value: float) -> void:
	Utils.set_bus_volume("master", value)
	_update_value_label(master_value_label, value)

func _on_music_slider_value_changed(value: float) -> void:
	Utils.set_bus_volume("music", value)
	_update_value_label(music_value_label, value)

func _on_voice_slider_value_changed(value: float) -> void:
	Utils.set_bus_volume("voice", value)
	_update_value_label(voice_value_label, value)

func _on_sfx_slider_value_changed(value: float) -> void:
	Utils.set_bus_volume("sfx", value)
	_update_value_label(sfx_value_label, value)

func _on_master_slider_drag_ended(_value_changed: bool) -> void:
	SaveAndLoad.update_settings()

func _on_music_slider_drag_ended(_value_changed: bool) -> void:
	SaveAndLoad.update_settings()

func _on_voice_slider_drag_ended(_value_changed: bool) -> void:
	SaveAndLoad.update_settings()

func _on_sfx_slider_drag_ended(_value_changed: bool) -> void:
	SaveAndLoad.update_settings()
	Sounds.play_sound("click", 1, -15)

func _on_close_button_pressed() -> void:
	queue_free()
