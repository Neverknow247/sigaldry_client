extends Control

var stats = Stats

@onready var rarity_label: Label = $rarity_label
@onready var label: Label = $label
@onready var reward_shape_grid: Control = $reward_shape_grid
@onready var color_bonuses: VBoxContainer = $color_bonuses
@onready var start_color: ColorRect = $color_bonuses/start_color
@onready var end_color: ColorRect = $color_bonuses/end_color

func set_rarity_label(rarity):
	rarity_label.text = rarity.capitalize()
	match rarity:
		"common":
			pass
		"uncommon":
			rarity_label.add_theme_color_override("font_color",Color(stats["COLOR_KEY"]["u"]))
		"rare":
			rarity_label.add_theme_color_override("font_color",Color(stats["COLOR_KEY"]["g"]))
		"epic":
			rarity_label.add_theme_color_override("font_color",Color(stats["COLOR_KEY"]["y"]))
		"legendary":
			rarity_label.add_theme_color_override("font_color",Color(stats["COLOR_KEY"]["o"]))
