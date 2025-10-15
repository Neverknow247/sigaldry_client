extends Control

var stats = Stats

@onready var rarity_label: Label = $rarity_label
@onready var label: Label = $label
@onready var reward_shape_grid: Control = $reward_shape_grid

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
