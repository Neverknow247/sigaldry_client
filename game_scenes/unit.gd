extends Control

var utils = Utils

const UNIT = preload("res://assets/art/card/unit.png")
const UNIT_AVATAR = preload("res://assets/art/card/unit.png")
const GRAY_SHADER = preload("res://assets/shaders/gray_unit.gdshader")

@onready var trap_content: CenterContainer = $trap_content
@onready var unit_content: Control = $unit_content

@onready var unit_image: TextureRect = $unit_content/unit_image
@onready var unit_texture: TextureRect = $unit_content/unit_texture

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
		$unit_content/unit_texture/stat_banner/attack_badge,
		$unit_content/unit_texture/stat_banner/attack_badge/attack_icon_badge,
		$unit_content/unit_texture/stat_banner/attack_badge/attack_icon_badge/attack_icon,
		$unit_content/unit_texture/stat_banner/health_badge,
		$unit_content/unit_texture/stat_banner/health_badge/health_icon_badge,
		$unit_content/unit_texture/stat_banner/health_badge/health_icon_badge/health_icon,
		#$unit_content/labels/unit_cost,
		#$unit_content/labels/unit_name,
		#$unit_content/labels/unit_effects,
		#$unit_content/labels/unit_attack,
		#$unit_content/labels/unit_health,
		#$unit_content/labels/unit_trapped
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
	#print("set_up: ",payload)
	unit_content.visible = payload["occupied"]
	trap_content.visible = payload["trapped"]
	tile_id = payload["id"]
	tile_type = payload["type"]
	#unit_type = "game_type"
	if payload["occupied"]:
		occupied = true
		occupant_id = payload["occupant"]["id"]
		occupant_type = payload["occupant"]["type"]
		if payload["occupant"]["name"]:
			unit_name.text = payload["occupant"]["name"]
		else:
			unit_name.text = ""
		unit_id = payload["occupant"]["id"]
		source_type = payload["occupant"]["subtype"]
		#grid_space["card"]["card_type"].text = info["occupant"]["subtype"].capitalize()
		if payload["occupant"]["subtype"] == "avatar":
			set_avatar(true)
		else:
			set_avatar(false)
		if payload["occupant"]["exhausted"]:
			set_grayscale(true)
			#unit_image.modulate = Color.BLACK
		else:
			set_grayscale(false)
			#unit_image.modulate = Color.WHITE
		var default_texture
		match payload["occupant"]["subtype"]:
			"unit","avatar":
				default_texture = load("res://assets/missing-images/none-unit.png")
			"spell":
				default_texture = load("res://assets/missing-images/none-spell.png")
			"trap":
				default_texture = load("res://assets/missing-images/none-trap.png")
			"potion":
				default_texture = load("res://assets/missing-images/none-potion.png")
		var tex = await CardArtCache.get_texture_async(str(payload["occupant"]["image"]),default_texture,true)
		unit_image.texture = tex
	else:
		occupied = false
		occupant_id = ""
		occupant_type = ""

func set_avatar(value):
	if value:
		unit_texture.texture = UNIT_AVATAR
	else:
		unit_texture.texture = UNIT

func update_unit(payload):
	unit_content.visible = !payload["unit"]["dead"]
	if !payload["unit"]["dead"]:
		if occupied == true:
			add_unit_effects(payload["unit"])
		if payload["unit"]["name"]:
			#grid_space["card"]["card_name"].text = info["unit"]["name"]
			pass
		else:
			#grid_space["card"]["card_name"].text = ""
			pass
		unit_id = payload["unit"]["id"]
		#grid_space["card"]["card_type"].text = info["unit"]["subtype"].capitalize()
		unit_type = "game_type"
		if payload["unit"]["exhausted"]:
			set_grayscale(true)
			#unit_image.modulate = Color.BLACK
		else:
			set_grayscale(false)
			#unit_image.modulate = Color.WHITE
		abilities = payload["unit"]["abilities"]
		
		var unit_effect_text = ""
		for ability_key in abilities:
			var ability = abilities[ability_key]
			match ability["name"]:
				"attack":
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
					#if ability["name"] == "actions":
						#card_actions.size.x = 36* (ability["value"])
						#if type != "potion":
							#continue
					var ability_value
					if is_equal_approx(ability["value"], int(ability["value"])):
						ability_value = str(int(ability["value"]))
					else:
						ability_value = str(ability["value"])
					unit_effect_text += "[url=" + ability["key"] + "]" + \
					ability["name"].capitalize() + "[/url]" + ":" \
					+ ability_value + "  "
		unit_effects.text = unit_effect_text
		
		#for ability in abilities:
			#if abilities[ability]["name"] == "health":
				#var card_hp = abilities[ability]["value"]
				##health = str(int(card_hp)) if card_hp > 0 else ""
				#unit_health.text = str(int(card_hp))
				#if abilities[ability]["value"] < abilities[ability]["max_value"]:
					#unit_health.add_theme_color_override("font_color", Color.RED)
				#else:
					#unit_health.add_theme_color_override("font_color", Color.BLACK)
			#elif abilities[ability]["name"] == "attack":
				#unit_attack.text = str(int(abilities[ability]["value"]))
				#pass
	else:
		unit_id = 0
		unit_type = ""
		set_grayscale(false)
		pass

func update_tile(payload):
	unit_content.visible = payload["tile"]["occupied"]
	trap_content.visible = payload["tile"]["trapped"]
	if payload["tile"]["occupied"]:
		if occupied == true:
			#add_unit_effects()
			#add_card_effects(grid_space,info["tile"]["occupant"])
			pass
		occupied = true
		occupant_id = payload["tile"]["occupant"]["id"]
		occupant_type = payload["tile"]["occupant"]["type"]
		abilities = payload["tile"]["occupant"]["abilities"]
		if payload["tile"]["occupant"]["name"]:
			unit_name.text = payload["tile"]["occupant"]["name"]
		else:
			unit_name.text = ""
		unit_id = payload["tile"]["occupant"]["id"]
		source_type = payload["tile"]["occupant"]["subtype"]
		#grid_space["card"]["card_id"] = info["tile"]["occupant"]["id"]
		#grid_space["card"]["source_type"] = info["tile"]["occupant"]["subtype"]
		#grid_space["card"]["card_type"].text = info["tile"]["occupant"]["subtype"].capitalize()
		if payload["tile"]["occupant"]["subtype"] == "avatar":
			set_avatar(true)
		else:
			set_avatar(false)
		if payload["tile"]["occupant"]["exhausted"]:
			set_grayscale(true)
			#unit_image.modulate = Color.BLACK
		else:
			set_grayscale(false)
			#unit_image.modulate = Color.WHITE
		for ability in abilities:
			if abilities[ability]["name"] == "health":
				var card_hp = abilities[ability]["value"]
				#unit_health.text = str(int(card_hp)) if card_hp > 0 else ""
				unit_health.text = str(int(card_hp))
				#grid_space["card"]["card_health"].text = str(int(card_hp)) if card_hp > 0 else ""
				if abilities[ability]["value"] < abilities[ability]["max_value"]:
					unit_health.add_theme_color_override("font_color", Color.RED)
				else:
					unit_health.add_theme_color_override("font_color", Color.BLACK)
			elif abilities[ability]["name"] == "attack":
				unit_attack.text = str(int(abilities[ability]["value"]))
		var default_texture
		match payload["tile"]["occupant"]["subtype"]:
			"unit","avatar":
				default_texture = load("res://assets/missing-images/none-unit.png")
			"spell":
				default_texture = load("res://assets/missing-images/none-spell.png")
			"trap":
				default_texture = load("res://assets/missing-images/none-trap.png")
			"potion":
				default_texture = load("res://assets/missing-images/none-potion.png")
		var tex = await CardArtCache.get_texture_async(str(payload["tile"]["occupant"]["image"]),default_texture,true)
		unit_image.texture = tex
	elif payload["tile"]["trapped"]:
		print("*****")
	else:
		occupied = false
		occupant_id = ""
		occupant_type = ""
	
	
	
	

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

func _on_unit_button_pressed() -> void:
	if occupied:
		tile_chosen.emit(occupant_id,occupant_type)
	else:
		tile_chosen.emit(tile_id,tile_type)

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
