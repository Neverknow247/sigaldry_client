extends Control

const AVATAR_TEXTURE = preload("res://assets/art/card_template_avatar.png")
const COLOR_PROFILE_SQUARE = preload("res://items/magnitude_square.tscn")

var stats = Stats

var KEYWORD_GLOSS = KeyWordGlossary

signal remove_from_deck(id)
signal add_avatar_to_deck(id)
signal add_to_deck(id)
signal select_card(id)
signal game_select_card()
signal mouse_focus(_pos,_focus,card_id)
signal add_avatar_to_new_deck(id)
signal get_info(data)
signal compare_card(id)
signal start_edit_card(id)

@onready var center_point: Control = $content/card_texture/center_point

@onready var content = $content
@onready var card_texture = $content/card_texture
@onready var card_image = $content/card_image
@onready var card_color_profile = $content/card_image/color_banner/card_color_profile
@onready var color_banner_animation_player: AnimationPlayer = $content/card_image/color_banner/color_banner_animation_player
@onready var stat_banner: TextureRect = $content/card_texture/main_banner/stat_banner
@onready var attack_badge: TextureRect = $content/card_texture/main_banner/stat_banner/attack_badge
@onready var health_badge: TextureRect = $content/card_texture/main_banner/stat_banner/health_badge
@onready var card_cost = $content/labels/card_cost
@onready var card_name = $content/labels/card_name
#@onready var card_effects = $content/labels/card_effects
@onready var card_attack = $content/labels/card_attack
@onready var card_health = $content/labels/card_health
@onready var card_type: Label = $content/card_texture/main_banner/stat_banner/card_type
@onready var card_author: Label = $content/card_author
@onready var card_actions = $content/labels/card_actions
@onready var card_rich_effects = $content/card_rich_effects
@onready var card_details: Control = $content/card_details
@onready var card_details_box: VBoxContainer = $content/card_details/card_details_background/content/scroll_container/card_details_box
@onready var card_details_timer: Timer = $content/card_details/card_details_timer
@onready var card_details_animation_player: AnimationPlayer = $content/card_details/card_details_animation_player

@onready var card_duplicate_number: ColorRect = $content/card_texture/card_duplicate_number
@onready var card_duplicate_number_label: Label = $content/card_texture/card_duplicate_number/card_duplicate_number_label

var type = ""
var source_type = ""
var card_id = 0

var card_button_type = null

@export var last_card  = false
var duplicated_details_ref = null
var card_details_open=  false:
	get:
		return card_details_open
	set(value):
		card_details_open = value
		match value:
			true:
				if !last_card: card_details_animation_player.play("open_card_details_right")
				else: card_details_animation_player.play("open_card_details_left")
			false:
				if !last_card: card_details_animation_player.play("close_card_details_right")
				else: card_details_animation_player.play("close_card_details_left")

#func duplicate_details(value):
	#match value:
		#true:
			#if duplicated_details_ref: duplicated_details_ref.queue_free()
			#var new_ref = card_details.duplicate(true)
			#if get_tree().current_scene.is_in_group("client"):
				#new_ref.z_index = 100
				#get_tree().current_scene.tooltips.add_child(new_ref)
				#new_ref.set_as_top_level(true)
				#new_ref.global_position = card_details.global_position
				#new_ref.scale = content.scale
				#duplicated_details_ref = new_ref
		#false:
			#if duplicated_details_ref: duplicated_details_ref.queue_free()

var color_banner_open =  false:
	get:
		return color_banner_open
	set(value):
		color_banner_open = value
		match value:
			true:
				color_banner_animation_player.play("open_color_banner")
			false:
				color_banner_animation_player.play("close_color_banner")

func define_scale(size):
	match size:
		1:
			custom_minimum_size = Vector2(81.6,112)
			content.scale = Vector2(.1,.1)
		2:
			custom_minimum_size = Vector2(163.2,224)
			content.scale = Vector2(.2,.2)
		3:
			custom_minimum_size = Vector2(244.8,336)
			content.scale = Vector2(.3,.3)
		4:
			custom_minimum_size = Vector2(326.4,448)
			content.scale = Vector2(.4,.4)
		5:
			custom_minimum_size = Vector2(408,560)
			content.scale = Vector2(.5,.5)
		8:
			custom_minimum_size = Vector2(816,1120)
			content.scale = Vector2(.8,.8)

func activate_avatar():
	card_texture = AVATAR_TEXTURE

func add_details(_card_details,_is_unit = false):
	#print("CARD DETAILS: ",_card_details)
	#print("*")
	#print("*")
	#print("*")
	#print("*")
	card_id = _card_details["id"]
	set_color_profile(_card_details["color_profile"])
	if is_equal_approx(_card_details["cost"], int(_card_details["cost"])):
		card_cost.text = str(int(_card_details["cost"]))
	else:
		card_cost.text = str(_card_details["cost"])
		card_cost.add_theme_font_size_override("font_size",48)
	if _card_details["name"]:
		set_card_name(_card_details["name"])
		#card_name.text = _card_name
	else:
		card_name.text = ""
	type = _card_details["subtype"]
	card_type.text = _card_details["subtype"].capitalize()
	hide_card_effects()
	#print(_card_details)
	set_card_effects(_card_details["abilities"])
	if !_is_unit:
		card_author.text = _card_details["meta"]["designer"]["user_name"]
	else:
		#print(_card_details)
		#card_author.text = _card_details["meta"]["designer"]["user_name"]
		card_author.text = _card_details["card"]["meta"]["designer"]["user_name"]
	
	
	var default_texture
	match _card_details["subtype"]:
		"avatar":
			default_texture = load("res://assets/missing-images/none-unit.png")
			stat_banner.texture = load("res://assets/art/card/banners/vertical_white.png")
			stat_banner.self_modulate = Color("b01cff")
			#card_actions.self_modulate = Color("b01cff")
			card_type.self_modulate = Color("b01cff")
			#card_texture.texture = load("res://assets/art/card/avatar-front.png")
			#stat_banner.texture = load("res://assets/art/card/banners/vertical-avatar.png")
		"unit":
			default_texture = load("res://assets/missing-images/none-unit.png")
			stat_banner.texture = load("res://assets/art/card/banners/vertical_white.png")
			stat_banner.self_modulate = Color("919191")
			#card_actions.self_modulate = Color("919191")
			card_type.self_modulate = Color("919191")
			#card_texture.texture = load("res://assets/art/card/unit-front.png")
			#stat_banner.texture = load("res://assets/art/card/banners/vertical-unit.png")
		"spell":
			default_texture = load("res://assets/missing-images/none-spell.png")
			stat_banner.texture = load("res://assets/art/card/banners/vertical_white_half.png")
			stat_banner.self_modulate = Color("0081ffff")
			card_type.self_modulate = Color("0081ffff")
			#card_texture.texture = load("res://assets/art/card/spell-front.png")
			#stat_banner.texture = load("res://assets/art/card/banners/vertical-spell.png")
		"trap":
			default_texture = load("res://assets/missing-images/none-trap.png")
			stat_banner.texture = load("res://assets/art/card/banners/vertical_white_half.png")
			stat_banner.self_modulate = Color("ff0000")
			card_type.self_modulate = Color("ff0000")
			#card_texture.texture = load("res://assets/art/card/trap-front.png")
			#stat_banner.texture = load("res://assets/art/card/banners/vertical-trap.png")
			
		"potion":
			default_texture = load("res://assets/missing-images/none-potion.png")
			stat_banner.texture = load("res://assets/art/card/banners/vertical_white.png")
			stat_banner.self_modulate = Color("00c843")
			card_type.self_modulate = Color("00c843")
			#card_texture.texture = load("res://assets/art/card/potion-front.png")
			#stat_banner.texture = load("res://assets/art/card/banners/vertical-potion.png")
	var tex = await CardArtCache.get_texture_async(str(_card_details["image"]),default_texture,true)
	#var tex = await CardArtCache.get_texture(_card_details["image"],default_texture)
	card_image.texture = tex
	
func set_card_name(_card_name):
	#var font_size = 50
	#match _card_name.length():
		#14: font_size = 52
		#13: font_size = 58
		#12: font_size = 60
		#11: font_size = 66
		#10: font_size = 72
		#9: font_size = 78
		#_:
			#pass
	#if _card_name.length() < 9:
		#font_size = 88
	#card_name.add_theme_font_size_override("font_size",font_size)
	card_name.text = _card_name
	
	#var image_path = "C:/sigaldry_images/%s" %[_card_details["image"]]
	#if FileAccess.file_exists(image_path):
		#var new_image = Image.new()
		#var error = new_image.load(image_path)
		#if error != OK:
			#push_error("Failed to load image: %s (err = %d)" %[image_path, error])
		#else:
			#var new_texture = ImageTexture.create_from_image(new_image)
			#card_image.texture = new_texture
	#else:
		#match _card_details["subtype"]:
			#"unit":
				#card_image.texture = load("res://assets/missing-images/none-unit.png")
			#"avatar":
				#card_image.texture = load("res://assets/missing-images/none-unit.png")
			#"spell":
				#card_image.texture = load("res://assets/missing-images/none-spell.png")
			#"trap":
				#card_image.texture = load("res://assets/missing-images/none-trap.png")
			#"potion":
				#card_image.texture = load("res://assets/missing-images/none-potion.png")
func hide_card_effects():
	card_actions.hide()
	card_attack.hide()
	card_health.hide()
	attack_badge.hide()
	health_badge.hide()

func set_card_effects(abilities):
	for child in card_details_box.get_children():
		card_details_box.remove_child(child)
		child.queue_free()
	var card_effect_text = ""
	for ability_key in abilities:
		var ability = abilities[ability_key]
		match ability["name"]:
			"strength":
				card_attack.show()
				attack_badge.show()
				card_attack.text = str(int(ability["value"]))
				if int(ability["value"]) < ability["value"]:
					card_attack.text += "+"
				#card_attack.text = str(ability["value"])
			"health":
				card_health.show()
				health_badge.show()
				card_health.text = str(int(ability["value"])) if ability["value"] > 0 else ""
				#print(ability)
				if int(ability["value"]) < ability["value"]:
					card_health.text += "+"
				#card_health.text = str(ability["value"]) if ability["value"] > 0 else ""
			#"actions":
				#card_actions.size.x = 36* (ability["value"])
				
			#"efficient":
				#pass
			_:
				if ability["name"] == "actions":
					card_actions.show()
					card_actions.size.y = 36* (ability["value"])
					#card_actions.size.x = 36* (ability["value"])
					if type != "potion":
						continue
				var ability_value
				if is_equal_approx(ability["value"], int(ability["value"])):
					ability_value = str(int(ability["value"]))
				else:
					ability_value = str(ability["value"])
				
				#card_effect_text += ability["name"].capitalize() + ":" \
				#+ ability_value + "  "
				card_effect_text += "[url=" + ability["key"] + "]" + \
				ability["name"].capitalize() + "[/url]" + ":" \
				+ ability_value + "  "
				
				#card_effect_text += "[url=" + ability["name"] + "]" + \
				#ability["name"].capitalize() + ": " + ability_value + "  "
				
				#var effect_label = preload("res://items/card_info_label.tscn").instantiate()
				#card_details_box.add_child(effect_label)
				#effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				#effect_label.text = "[url=" + ability["key"] + "]" + \
				#ability["name"].capitalize() + "[/url]" + ": "
				#effect_label.text += KEYWORD_GLOSS.key_glossary[ability["key"]]["description"]
				
				#effect_label.top_level = true
	card_rich_effects.text = card_effect_text

func set_color_profile(colors):
	#print(colors)
	for _child in card_color_profile.get_children():
		card_color_profile.remove_child(_child)
		_child.queue_free()
	for color_key in colors:
		var color =  colors[color_key]
		var new_color = COLOR_PROFILE_SQUARE.instantiate()
		card_color_profile.add_child(new_color)
		new_color.color_square.color = Color(stats.COLOR_KEY[color["key"]])
		var color_magnitude = 0
		color_magnitude += int(color["magnitude"])
		new_color.color_magnitude.text = str(color_magnitude)
		#new_color.color_magnitude.text += str(int(color["magnitude"]))

func set_avatar():
	print("Add Avatar Image")

func set_card_duplicate_number(number):
	card_duplicate_number.show()
	card_duplicate_number_label.text = "X%s" %[str(number)]

func _on_card_button_pressed():
	print("Card Type: ",card_button_type," | Card ID: ",card_id)
	match card_button_type:
		"collection":
			start_edit_card.emit(card_id)
		"avatar_deck_editor_in_deck":
			pass
		"deck_editor_in_deck":
			remove_from_deck.emit(card_id)
		"deck_editor_not_in_deck":
			add_to_deck.emit(card_id)
		"game_card_select":
			select_card.emit(card_id)
		"game_type":
			game_select_card.emit()
		"builder_compare_select":
			compare_card.emit(card_id)
		"preview_select":
			compare_card.emit(card_id)
		"select":
			select_card.emit(card_id)
		_:
			#print("Card Type: ",card_button_type," | Card ID: ",card_id)
			print("No Type")
			return

#func _on_card_button_mouse_entered() -> void:
	#return
	#card_details_timer.start(card_details_timer.wait_time)
#
#func _on_card_button_mouse_exited() -> void:
	#return
	#card_details_timer.stop()
	#card_details.hide()

func _on_card_details_timer_timeout() -> void:
	card_details.show()

func _on_color_banner_button_pressed() -> void:
	if !color_banner_animation_player.is_playing():
		color_banner_open = !color_banner_open

func _on_card_details_button_pressed() -> void:
	if !card_details_animation_player.is_playing():
		card_details_open = !card_details_open
		

func _on_card_button_mouse_entered() -> void:
	if card_button_type == "game_type":
		mouse_focus.emit(center_point.global_position,true,card_id,source_type)

func _on_card_button_mouse_exited() -> void:
	if card_button_type == "game_type":
		mouse_focus.emit(center_point.global_position,true,card_id,source_type)

func _on_card_button_get_info() -> void:
	if card_button_type == "game_type":
		get_info.emit({"type":"card","id":card_id})
