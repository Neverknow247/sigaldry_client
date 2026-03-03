extends Control

var stats = Stats

const CARD_SCENE = preload("res://items/card.tscn")
const card_preview = preload("res://items/card_preview.tscn")
#const card_preview = preload("res://items/card.tscn")
const COLOR_PROFILE_SQUARE_LARGE = preload("res://items/color_profile_square_large.tscn")

@onready var card_image: TextureRect = $compare_card/card_image
@onready var card_texture: TextureRect = $compare_card/card_texture
@onready var attack_badge: TextureRect = $compare_card/card_texture/stat_banner/attack_badge
@onready var health_badge: TextureRect = $compare_card/card_texture/stat_banner/health_badge
@onready var card_actions: TextureRect = $compare_card/labels/card_actions

@onready var card_name: Label = $compare_card/labels/card_name
@onready var card_rich_effects: RichTextLabel = $compare_card/labels/card_rich_effects
@onready var card_price: Label = $compare_card/labels/card_price
@onready var card_attack: Label = $compare_card/labels/card_attack
@onready var card_health: Label = $compare_card/labels/card_health
@onready var card_type: Label = $compare_card/labels/card_type
@onready var card_color_profile = $compare_card/card_color_profile

var type = ""

var binder_width = 5

@onready var card_select_screen = $card_select_screen
@onready var scroll_container = $card_select_screen/ScrollContainer
@onready var v_box_container = $card_select_screen/ScrollContainer/VBoxContainer
@onready var compare_card = $compare_card

#func add_cards(payload):
	##print(payload)
	#for n in v_box_container.get_children():
		#v_box_container.remove_child(n)
		#n.queue_free()
	#var card_number = 0
	#var row_node
	#var first_card = true
	#for card in payload["cards"]:
		#if first_card:
			#first_card = false
		#if card_number == 0:
			#row_node = HBoxContainer.new()
			#v_box_container.add_child(row_node)
			#row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			#row_node.add_theme_constant_override("separation", 25)
		#var new_card = card_preview.instantiate()
		#row_node.add_child(new_card)
		#new_card.define_scale(4)
		#new_card.add_details(card)
		#
		#card_number+=1
		#if card_number == binder_width:
			#card_number = 0
#
#func add_compare_card(card_id):
	#compare_card.show()
	#for child in card_color_profile.get_children():
		#card_color_profile.remove_child(child)
		#child.queue_free()
	#for row in v_box_container.get_children():
		#for card in row.get_children():
			#if card.card_id == card_id:
				#for child in card.card_color_profile.get_children():
					#var new_color = COLOR_PROFILE_SQUARE_LARGE.instantiate()
					#card_color_profile.add_child(new_color)
					#new_color.color_square.color = child.color_square.color
					#new_color.color_magnitude.text = child.color_magnitude.text
				#card_select_screen.hide()
				#card_name.text = card["card_name"].text
				#card_attack.text = card["card_attack"].text
				#card_type.text = card["card_type"].text
				#card_health.text = card["card_health"].text
				#card_price.text = card["card_price"].text
				#card_effects.text = card["card_effects"].text


func add_cards(payload):
	for n in v_box_container.get_children():
		v_box_container.remove_child(n)
		n.queue_free()
	var card_number = 0
	var row_node
	var first_card = true
	for card in payload:
		if first_card:
			first_card = false
		if card_number == 0:
			row_node = HBoxContainer.new()
			v_box_container.add_child(row_node)
			row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			row_node.add_theme_constant_override("separation",25)
		var new_card = CARD_SCENE.instantiate()
		row_node.add_child(new_card)
		new_card.define_scale(4)
		new_card.add_details(card)
		new_card["card_button_type"] = "builder_compare_select"
		new_card.connect("compare_card",add_compare_card)
		card_number+=1
		if card_number == binder_width:
			new_card.last_card  = true
			card_number = 0
	#show()

#func add_cards(payload):
		#var new_card = card_preview.instantiate()
		#new_card["card_id"] = card["id"]
		#new_card["type"] = "builder_compare"
		#new_card.connect("compare_card",add_compare_card)
		#row_node.add_child(new_card)
		#new_card["card_name"].text = card["card"]["name"]
		#new_card["card_type"].text = card["card"]["subtype"].capitalize()
		#var card_effect_text = ""
		#var discount = 0
		##print(card)
		#if card["card"]["keywords"]:
			#for ability in card["card"]["keywords"]:
				##print(ability)
				#if ability["name"] == "health":
					#var card_hp = ability["value"]
					#new_card["card_health"].text = str(int(card_hp)) if card_hp > 0 else ""
				#elif ability["name"] == "attack":
					#new_card["card_attack"].text = str(int(ability["value"]))
				#elif ability["name"] == "actions":
					#pass
				#elif ability["name"] == "efficient":
					#discount = ability["value"]
				#elif ability["value"] > 0:
					#card_effect_text += ability["name"].capitalize() + "-" \
					#+ str(int(ability["value"])) + "  " 
		#new_card["card_effects"].text = card_effect_text
		#new_card["card_price"].text = str(int(card["card"]["cost"]-discount))
		#
		#for _child in new_card.card_color_profile.get_children():
			#new_card.card_color_profile.remove_child(_child)
			#_child.queue_free()
		#for color in card["card"]["color_profile"]:
			#var new_color = COLOR_PROFILE_SQUARE_LARGE.instantiate()
			#new_card.card_color_profile.add_child(new_color)
			#new_color.color_square.color = Color(stats.COLOR_KEY[color["id"]])
			#new_color.color_magnitude.text = str(int(color["magnitude"]))
		#
		#card_number+=1
		#if card_number == binder_width:
			#card_number = 0

func add_compare_card(card_id):
	compare_card.show()
	for child in card_color_profile.get_children():
		card_color_profile.remove_child(child)
		child.queue_free()
	for row in v_box_container.get_children():
		for card in row.get_children():
			if card.card_id == card_id:
				for child in card.card_color_profile.get_children():
					var new_color = COLOR_PROFILE_SQUARE_LARGE.instantiate()
					card_color_profile.add_child(new_color)
					new_color.color_square.color = child.color_square.color
					new_color.color_magnitude.text = child.color_magnitude.text
				card_select_screen.hide()
				card_name.text = card["card_name"].text
				card_attack.text = card["card_attack"].text
				card_type.text = card["card_type"].text
				card_health.text = card["card_health"].text
				card_price.text = card["card_cost"].text
				card_rich_effects.text = card["card_rich_effects"].text
				card_image.texture = card["card_image"].texture
				
				#set_card_effects(card["card_effects"].text)
				#card_effects.text = card["card_effects"].text

#func set_card_effects(abilities):
	#var card_effect_text = ""
	#for ability_key in abilities:
		#var ability = abilities[ability_key]
		#match ability["name"]:
			#"strength":
				#card_attack.show()
				#attack_badge.show()
				#card_attack.text = str(int(ability["value"]))
				#if int(ability["value"]) < ability["value"]:
					#card_attack.text += "+"
				##card_attack.text = str(ability["value"])
			#"health":
				#card_health.show()
				#health_badge.show()
				#card_health.text = str(int(ability["value"])) if ability["value"] > 0 else ""
				##print(ability)
				#if int(ability["value"]) < ability["value"]:
					#card_health.text += "+"
				##card_health.text = str(ability["value"]) if ability["value"] > 0 else ""
			##"actions":
				##card_actions.size.x = 36* (ability["value"])
				#
			##"efficient":
				##pass
			#_:
				#if ability["name"] == "actions":
					#card_actions.show()
					#card_actions.size.y = 36* (ability["value"])
					##card_actions.size.x = 36* (ability["value"])
					#if type != "potion":
						#continue
				#var ability_value
				#if is_equal_approx(ability["value"], int(ability["value"])):
					#ability_value = str(int(ability["value"]))
				#else:
					#ability_value = str(ability["value"])
				#
				##card_effect_text += ability["name"].capitalize() + ":" \
				##+ ability_value + "  "
				#card_effect_text += "[url=" + ability["key"] + "]" + \
				#ability["name"].capitalize() + "[/url]" + ":" \
				#+ ability_value + "  "
				#
				##card_effect_text += "[url=" + ability["name"] + "]" + \
				##ability["name"].capitalize() + ": " + ability_value + "  "
				#
				##var effect_label = preload("res://items/card_info_label.tscn").instantiate()
				##card_details_box.add_child(effect_label)
				##effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				##effect_label.text = "[url=" + ability["key"] + "]" + \
				##ability["name"].capitalize() + "[/url]" + ": "
				##effect_label.text += KEYWORD_GLOSS.key_glossary[ability["key"]]["description"]
				#
				##effect_label.top_level = true
	#card_rich_effects.text = card_effect_text
