extends Control

var utils = Utils

const UNIT = preload("res://assets/art/card/unit.png")
const UNIT_AVATAR = preload("res://assets/art/card/unit.png")
const GRAY_SHADER = preload("res://assets/shaders/gray_unit.gdshader")

@onready var trap_content: CenterContainer = $trap_content
@onready var unit_content: Control = $unit_content

@onready var unit_image: TextureRect = $unit_content/unit_image
@onready var unit_texture: TextureRect = $unit_content/unit_texture

@onready var avatar_icon_badge: TextureRect = $unit_content/unit_texture/stat_banner/avatar_icon_badge

@onready var unit_cost: Label = $unit_content/labels/unit_cost
@onready var unit_name: Label = $unit_content/labels/unit_name
@onready var unit_effects: RichTextLabel = $unit_content/labels/unit_effects
@onready var unit_attack: Label = $unit_content/labels/unit_attack
@onready var unit_health: Label = $unit_content/labels/unit_health
@onready var unit_trapped: Label = $unit_content/labels/unit_trapped

@onready var unit_select_button: Button = $unit_content/unit_select_button
@onready var unit_select_timer: Timer = $unit_content/unit_select_timer
@onready var unit_select_path: Path2D = $unit_content/unit_select_path
@onready var unit_select_line: Line2D = $unit_content/unit_select_line

@onready var unit_button: Button = $unit_button
@onready var unit_button_color: ColorRect = $unit_button/unit_button_color

var grayscale_array : Array

@export var default_color : Color = Color("00000000")
@export var friendly_color : Color = Color("00ff007d")
@export var unfriendly_color : Color = Color("ff00007d")
@export var move_color : Color = Color("0000ff7d")

var original_unit_data = {}
var updated_unit_data = {}

var tile_id = ""
var tile_type = ""
var occupied = false
var occupant_id = ""
var occupant_type = ""

var unit_type = ""
var source_type = ""
var unit_id = 0

var abilities = {}
var health = ""

signal tile_chosen(id)
signal mouse_focus(_pos,_focus,card_id,type)
#signal get_info(data)

func _ready() -> void:
	set_up_grayscale_array()
	apply_gray_shader()
	set_grayscale(false)

func set_up_grayscale_array():
	grayscale_array = [
		$unit_content/unit_image,
		$unit_content/unit_texture,
		$unit_content/unit_texture/main_banner,
		$unit_content/unit_texture/stat_banner,
		$unit_content/unit_texture/stat_banner/avatar_icon_badge,
		$unit_content/unit_texture/stat_banner/avatar_icon_badge/avatar_icon,
		$unit_content/unit_texture/stat_banner/attack_badge,
		$unit_content/unit_texture/stat_banner/attack_badge/attack_icon_badge,
		$unit_content/unit_texture/stat_banner/attack_badge/attack_icon_badge/attack_icon,
		$unit_content/unit_texture/stat_banner/health_badge,
		$unit_content/unit_texture/stat_banner/health_badge/health_icon_badge,
		$unit_content/unit_texture/stat_banner/health_badge/health_icon_badge/health_icon,
	]

func apply_gray_shader():
	for child in grayscale_array:
		if child.material == null:
			var mat := ShaderMaterial.new()
			mat.shader = GRAY_SHADER
			child.material = mat
		elif child.material is ShaderMaterial:
			child.material.shader = GRAY_SHADER

func set_grayscale(enabled):
	var amount = 1.0 if enabled else 0.0
	for child in grayscale_array:
		child.material.set_shader_parameter("gray_amount",amount)

func set_up_unit(payload):
	unit_content.visible = payload["occupied"]
	trap_content.visible = payload["trapped"]
	unit_trapped.visible = payload["trapped"]
	tile_id = payload["id"]
	tile_type = payload["type"]
	if payload["occupied"]:
		occupied = true
		occupant_id = payload["occupant"]["id"]
		occupant_type = payload["occupant"]["type"]
		source_type = payload["occupant"]["subtype"]
		update_unit_content(payload["occupant"])
		add_unit_texture(payload["occupant"])
	else:
		occupied = false
		occupant_id = ""
		occupant_type = ""

func set_avatar(value):
	if value:
		avatar_icon_badge.show()
		unit_texture.texture = UNIT_AVATAR
	else:
		avatar_icon_badge.hide()
		unit_texture.texture = UNIT

func update_unit(payload):
	unit_content.visible = !payload["dead"]
	if !payload["dead"]:
		if occupied == true:
			add_unit_effects(payload)
		unit_type = "game_type"
		update_unit_content(payload)
	else:
		unit_id = 0
		unit_type = ""
		set_grayscale(false)
		pass

func update_tile(payload):
	unit_content.visible = payload["tile"]["occupied"]
	trap_content.visible = payload["tile"]["trapped"]
	unit_trapped.visible = payload["tile"]["trapped"]
	if payload["tile"]["occupied"]:
		if occupied == true:
			#add_unit_effects()
			#add_card_effects(grid_space,info["tile"]["occupant"])
			pass
		occupied = true
		occupant_id = payload["tile"]["occupant"]["id"]
		occupant_type = payload["tile"]["occupant"]["type"]
		source_type = payload["tile"]["occupant"]["subtype"]
		update_unit_content(payload["tile"]["occupant"])
		add_unit_texture(payload["tile"]["occupant"])
	elif payload["tile"]["trapped"]:
		print("*****")
	else:
		occupied = false
		occupant_id = ""
		occupant_type = ""

func update_unit_content(payload):
	unit_id = payload["id"]
	if payload["name"]:
		unit_name.text = payload["name"]
	else:
		unit_name.text = ""
	if payload["exhausted"]:
		set_grayscale(true)
	else:
		set_grayscale(false)
	abilities = payload["abilities"]
	var unit_effect_text = ""
	for ability_key in abilities:
		var ability = abilities[ability_key]
		match ability["name"]:
			"strength":
				unit_attack.text = str(int(ability["value"]))
			"health":
				unit_health.text = str(int(ability["value"])) if ability["value"] > 0 else ""
				if ability["value"] < ability["max_value"]:
					unit_health.add_theme_color_override("font_color", Color.RED)
				else:
					unit_health.add_theme_color_override("font_color", Color.BLACK)
			"actions":
				pass
			_:
				var ability_value
				if is_equal_approx(ability["value"], int(ability["value"])):
					ability_value = str(int(ability["value"]))
				else:
					ability_value = str(ability["value"])
				unit_effect_text += "[url=" + ability["key"] + "]" + \
				ability["name"].capitalize() + "[/url]" + ":" \
				+ ability_value + "  "
	unit_effects.text = unit_effect_text

func add_unit_texture(payload):
	if payload["subtype"] == "avatar":
		set_avatar(true)
	else:
		set_avatar(false)
	var default_texture
	match payload["subtype"]:
		"avatar":
			default_texture = load("res://assets/missing-images/none-unit.png")
			unit_texture.texture = load("res://assets/art/card/avatar_unit.png")
		"unit":
			default_texture = load("res://assets/missing-images/none-unit.png")
			#unit_texture.texture = 
		"spell":
			default_texture = load("res://assets/missing-images/none-spell.png")
		"trap":
			default_texture = load("res://assets/missing-images/none-trap.png")
		"potion":
			default_texture = load("res://assets/missing-images/none-potion.png")
	var tex = await CardArtCache.get_texture_async(str(payload["image"]),default_texture,true)
	unit_image.texture = tex

func add_unit_effects(payload):
	return
	var effects = []
	for ability in payload["abilities"]:
		for second_ability in payload["abilities"]:
			if ability == second_ability:
				var diff = payload["abilities"][ability]["value"] - abilities[ability]["value"]
				if diff != 0:
					var effect_dict = {
						"ability" : str(ability),
						"sign" : "+" if diff > 0 else "-",
						"diff_value" : abs(diff),
						"original_value" : abilities[ability]["value"],
						"new_value" : payload["abilities"][ability]["value"],
					}
					effects.push_front(effect_dict)
	#game_effect_queue.add_to_queue(effects)

var target_type = ""
func _on_unit_button_pressed() -> void:
	if target_type == "unit":
		tile_chosen.emit(occupant_id,occupant_type)
	else:
		tile_chosen.emit(tile_id,tile_type)
	#if occupied:
		#tile_chosen.emit(occupant_id,occupant_type)
	#else:
		#tile_chosen.emit(tile_id,tile_type)

func disable_button(disable:bool):
	unit_button.disabled = disable
	unit_button_color.color = default_color

func edit_theme_graphic(_target):
	var target = _target
	if target["action"] == "move":
		unit_button_color.color = move_color
	elif target["action"] == "play" || target["action"] == "use":
		if target["disposition"] == "friendly":
			unit_button_color.color = friendly_color
		elif target["disposition"] == "unfriendly":
			unit_button_color.color = unfriendly_color

func _on_unit_select_button_mouse_entered() -> void:
	mouse_focus.emit(global_position+Vector2(127,137),true,unit_id,source_type)

func _on_unit_select_button_mouse_exited() -> void:
	mouse_focus.emit(global_position+Vector2(127,137),false,unit_id,source_type)

func _on_unit_texture_mouse_entered() -> void:
	unit_select_button.show()

func _on_unit_texture_mouse_exited() -> void:
	#unit_select_button.show()
	return
