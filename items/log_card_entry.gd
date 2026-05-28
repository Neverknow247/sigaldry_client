extends HBoxContainer

signal card_thumbnail_clicked(card_data: Dictionary)

@onready var thumbnail: TextureButton = $texture_button
@onready var text_label: RichTextLabel = $rich_text_label

var card_data: Dictionary = {}

func setup(entry_text: String, incoming_card_data: Dictionary, image_texture: Texture2D):
	card_data = incoming_card_data
	text_label.text = entry_text
	thumbnail.texture_normal = image_texture
	thumbnail.custom_minimum_size = Vector2(42,58)
	thumbnail.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

func _ready() -> void:
	thumbnail.pressed.connect(_on_thumbnail_pressed)

func _on_thumbnail_pressed():
	card_thumbnail_clicked.emit(card_data)
