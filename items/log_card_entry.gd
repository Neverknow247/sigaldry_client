extends Button

signal card_entry_clicked(card_data)
signal card_entry_hover_started(card_data)
signal card_entry_hover_ended
signal card_entry_right_clicked(card_data)

@onready var card_thumbnail: TextureRect = $card_thumbnail
@onready var card_name: Label = $card_name

var card_data := {}

func _ready() -> void:
	mouse_entered.connect(func():
		if not card_data.is_empty():
			card_entry_hover_started.emit(card_data)
	)
	mouse_exited.connect(func():
		card_entry_hover_ended.emit()
	)
	gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				if not card_data.is_empty():
					card_entry_right_clicked.emit(card_data)
	)

func set_card_data(data: Dictionary) -> void:
	custom_minimum_size = Vector2(72, 72)
	size = Vector2(72, 72)
	card_thumbnail.custom_minimum_size = Vector2(64, 64)
	card_thumbnail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card_thumbnail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card_name.hide()

	card_data = data.duplicate(true)
	card_name.text = str(card_data.get("name", card_data.get("base_name", "Card")))

	var default_texture = load("res://assets/missing-images/none-unit.png")
	if card_data.has("image"):
		card_thumbnail.texture = await CardArtCache.get_texture_async(str(card_data["image"]), default_texture, true)

func _pressed() -> void:
	card_entry_clicked.emit(card_data)
