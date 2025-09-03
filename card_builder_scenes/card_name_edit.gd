extends Control

var scene_name = "card_name_edit"

var stats = Stats
var KEYWORD_GLOSS = KeyWordGlossary

const CARD_SCENE = preload("res://items/card.tscn")

@onready var background_color: ColorRect = $background_color

func _ready():
	background_color.color = stats.background_color
