extends Control

var scene_name = "game"

var stats = Stats

#const card_preview = preload("res://items/card_preview.tscn")
const CARD_SCENE = preload("res://items/card.tscn")

signal end_turn
signal concede
signal get_info(data)

@onready var side_panel_background = $side_panel/side_panel_background
@onready var game = $side_panel/side_tabs/Game
@onready var card_view = $"side_panel/side_tabs/Card View"
@onready var log_visuals = $side_panel/side_tabs/Log

@onready var battlefield = $battlefield

@onready var side_tabs = $side_panel/side_tabs

@onready var card_view_card = $"side_panel/side_tabs/Card View/card_view_card"

@onready var log_container = $side_panel/side_tabs/Log/ScrollContainer/log_container
@onready var first_log = $side_panel/side_tabs/Log/ScrollContainer/log_container/first_log

@onready var enemy_energy = $side_panel/side_tabs/Game/enemy_panel/energy/enemy_energy
@onready var enemy_hand_size = $side_panel/side_tabs/Game/enemy_panel/cards_in_hand/enemy_hand_size
@onready var enemy_deck_size = $side_panel/side_tabs/Game/enemy_panel/cards_in_deck/enemy_deck_size
@onready var enemy_victory_points = $side_panel/side_tabs/Game/enemy_panel/victory_points/enemy_victory_points

@onready var hand = $side_panel/side_tabs/Game/hand_preview/hand

@onready var my_energy = $side_panel/side_tabs/Game/player_panel/info/energy/my_energy
@onready var my_hand_size = $side_panel/side_tabs/Game/player_panel/info/cards_in_hand/my_hand_size
@onready var my_deck_size = $side_panel/side_tabs/Game/player_panel/info/cards_in_deck/my_deck_size
@onready var my_victory_points = $side_panel/side_tabs/Game/player_panel/info/victory_points/my_victory_points

@onready var end_turn_button = $side_panel/side_tabs/Game/player_panel/buttons/end_turn_button

@onready var timer = $card_controller/Timer
@onready var path_2d = $card_controller/Path2D
@onready var line_2d = $card_controller/Line2D

@onready var combat_action_timer = $combat_action_controller/combat_action_timer
@onready var combat_action_path = $combat_action_controller/combat_action_path
@onready var combat_action_line = $combat_action_controller/combat_action_line

@onready var turn_timer_left = $battlefield/turn_timer/turn_timer_left
@onready var turn_timer_right = $battlefield/turn_timer/turn_timer_right
@onready var turn_timer_count = $battlefield/turn_timer/turn_timer_graphic/turn_timer_count

var card_view_id = ""

var battlefield_data = null
var click_hover = false
var card_middle = Vector2(128,176)
var disposition_override = false:
	set(value):
		disposition_override = value
		battlefield.change_disposition(value)
	get():
		return disposition_override

var my_turn = true

signal mouse_released
#signal picked_up_changed(picked)
signal focus(_focus)

func _ready():
	set_color_backgrounds()
	path_2d.curve = Curve2D.new()
	path_2d.curve.add_point(global_position)
	#path_2d.curve.add_point(global_position)
	path_2d.curve.bake_interval = 50

@warning_ignore("unused_parameter")
func _process(delta):
	if picked_up:
		path_2d.curve.set_point_position(1,get_local_mouse_position()-card_middle)
		path_2d.curve.set_point_in(1,(Vector2(get_local_mouse_position().x-1000,get_local_mouse_position().y)/2)*-1)
		#path_2d.curve.set_point_in(1,Vector2(get_local_mouse_position().x,(get_local_mouse_position().y-card_middle.y)/2)*-1)
		_draw_line()
	if Input.is_action_just_released("M1"):
		mouse_released.emit()
	if Input.is_action_just_pressed("disposition_override"):
		disposition_override = !disposition_override
	if Input.is_action_just_pressed("M2") and picked_up:
		picked_up = false
		mouse_released.emit()

func set_color_backgrounds():
	side_panel_background.color = stats.background_color
	game.color = stats.background_color
	card_view.color = stats.background_color
	log_visuals.color = stats.background_color

func join_game(payload):
	await battlefield.create_grid(payload["board"]["cols"],payload["board"]["rows"])
	#print("join game: ",payload)
	battlefield_data = payload["board"]["tiles"]
	for tile in battlefield_data:
		#print(tile)
		battlefield.set_grid_space(tile)
		#battlefield.grid[tile["game_y"]][tile["game_x"]].connect("tile_chosen",_set_battle_field_tile)
		battlefield.grid[tile["display_y"]][tile["display_x"]].connect("tile_chosen",_set_battle_field_tile)
		
		#var grid_space = battlefield["grid"][tile["game_y"]][tile["game_x"]]
		var grid_space = battlefield["grid"][tile["display_y"]][tile["display_x"]]
		#here
		grid_space["card"]["card_select"].connect("pressed",_on_card_select_pressed)
		grid_space["card"].connect("mouse_focus",_on_card_select_mouse_focus)
		grid_space.connect("get_info",_on_card_get_info)
		
		

@warning_ignore("unused_parameter")
func quit_game(payload):
	card_view_card.hide()
	card_view_id = ""
	for tile in battlefield_data:
		#var grid_space = battlefield["grid"][tile["game_y"]][tile["game_x"]]
		var grid_space = battlefield["grid"][tile["display_y"]][tile["display_x"]]
		if grid_space.is_connected("tile_chosen",_set_battle_field_tile):
			grid_space.disconnect("tile_chosen",_set_battle_field_tile)
		if grid_space["card"]["card_select"].is_connected("pressed",_on_card_select_pressed):
			grid_space["card"]["card_select"].disconnect("pressed",_on_card_select_pressed)
		if grid_space["card"].is_connected("mouse_focus",_on_card_select_mouse_focus):
			grid_space["card"].disconnect("mouse_focus",_on_card_select_mouse_focus)

func update_unit(payload):
	#print("unit selected: ", card_view_id)
	#print("update unit: ",payload)
	print("here")
	print(str(payload["unit"]["id"]),":",card_view_id)
	if str(payload["unit"]["id"]) == card_view_id:
		card_view_card.add_details(payload["unit"])
		#update_card_view(payload["unit"])
	#print("update unit: ",payload["unit"]["x"])
	battlefield.update_unit(payload)
	pass

func update_turn(payload):
	#print("update turn: ",payload)
	if payload["active_avatar_id"]:
		if payload["active_avatar_id"] == payload["my_avatar_id"]:
			my_turn = true
			end_turn_button.text = "End Turn"
			end_turn_button.disabled = false
		else:
			my_turn = false
			end_turn_button.text = "Opponent's Turn"
			end_turn_button.disabled = true
	if payload.has("ticks_remaining"):
		turn_timer_count.text = str(int(payload["ticks_remaining"]))
		turn_timer_right.max_value = payload["ticks_in_turn"]
		turn_timer_right.value = payload["ticks_remaining"]
		turn_timer_left.max_value = payload["ticks_in_turn"]
		turn_timer_left.value = payload["ticks_remaining"]

func add_combat_log(payload):
	var new_log = preload("res://items/game_log_label.tscn").instantiate()
	first_log.add_sibling(new_log)
	new_log.text = payload["statement"]
	#print("add combat log: ")
	#print("add combat log: ",payload["arguments"])
	#print("argument size: ",payload["arguments"].size())
	#for item in payload["arguments"]:
		#print(item)

func update_energy(payload):
	my_energy.text = str(int(payload["energy"]))
	enemy_energy.text = str(int(payload["opponent_energy"]))

#func update_players(payload):
	##print(payload)
	#for key in payload:
		#print(key)
	#my_deck_size.text = str(int(payload["my_deck_size"]))
	#enemy_deck_size.text = str(int(payload["opponent_deck_size"]))
	#my_hand_size.text = str(int(payload["my_hand_size"]))
	#enemy_hand_size.text = str(int(payload["opponent_hand_size"]))
	#my_energy.text = str(int(payload["my_energy"]))
	#enemy_energy.text = str(int(payload["opponent_energy"]))
	##my_victory_points.text = str(int(payload["my_victory_points"]))
	##enemy_victory_points.text = str(int(payload["opponent_victory_points"]))
	#var hand_width = 2
	#var card_number = 0
	#var row_node
	#for child in hand.get_children():
		#hand.remove_child(child)
		#child.queue_free()
	#for unit in payload["my_hand"]:
		#print("******************")
		#print("Card: ",unit)
		#print("******************")
		#if card_number == 0:
			#row_node = HBoxContainer.new()
			#hand.add_child(row_node)
			#row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			#row_node.add_theme_constant_override("separation",10)
		#var new_card = card_preview.instantiate()
		#row_node.add_child(new_card)
		#new_card["card_name"].text = unit["name"]
		#new_card["card_id"] = unit["id"]
		#new_card["source_type"] = "card"
		##print("hand unit id",unit["id"])
		#new_card["card_type"].text = unit["subtype"].capitalize()
		#new_card["type"] = "game_type"
		#new_card["card_select"].connect("pressed",_on_card_select_pressed)
		#new_card.connect("mouse_focus",_on_card_select_mouse_focus)
		#new_card.connect("get_info",_on_card_get_info)
		#var card_effect_text = ""
		#var _discount = 0
		#for ability in unit["abilities"]:
			##print(ability)
			#if unit["abilities"][ability]["name"] == "health":
				#new_card["card_health"].text = str(int(unit["abilities"][ability]["value"]))
			#elif unit["abilities"][ability]["name"] == "attack":
				#new_card["card_attack"].text = str(int(unit["abilities"][ability]["value"]))
			#elif unit["abilities"][ability]["name"] == "actions":
				#pass
			#elif unit["abilities"][ability]["name"] == "efficient":
				#_discount = unit["abilities"][ability]["value"]
			#elif unit["abilities"][ability]["value"] > 0:
				#card_effect_text += unit["abilities"][ability]["name"].capitalize() + "-" + str(int(unit["abilities"][ability]["value"])) + " "
		#new_card["card_effects"].text = card_effect_text
		#new_card["card_price"].text = str(int(unit["cost"]))
		#card_number+=1
		#if card_number == hand_width:
			#card_number = 0

	#var new_card = CARD_SCENE.instantiate()
	#container.add_child(new_card)
	#new_card.define_scale(3)
	#new_card.add_details(card)
	#new_card.card_button_type = "select"
	#new_card.connect("select_card",select_card)

func update_players(payload):
	#print(payload)
	#for key in payload:
		#print(key)
	my_deck_size.text = str(int(payload["my_deck_size"]))
	enemy_deck_size.text = str(int(payload["opponent_deck_size"]))
	my_hand_size.text = str(int(payload["my_hand_size"]))
	enemy_hand_size.text = str(int(payload["opponent_hand_size"]))
	my_energy.text = str(int(payload["my_energy"]))
	enemy_energy.text = str(int(payload["opponent_energy"]))
	#my_victory_points.text = str(int(payload["my_victory_points"]))
	#enemy_victory_points.text = str(int(payload["opponent_victory_points"]))
	var hand_width = 2
	var card_number = 0
	var row_node
	for child in hand.get_children():
		hand.remove_child(child)
		child.queue_free()
	for unit in payload["my_hand"]:
		#print("******************")
		#print("Card: ",unit)
		#print("******************")
		if card_number == 0:
			row_node = HBoxContainer.new()
			hand.add_child(row_node)
			row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			row_node.add_theme_constant_override("separation",10)
		var new_card = CARD_SCENE.instantiate()
		row_node.add_child(new_card)
		new_card.define_scale(3)
		new_card.add_details(unit)
		new_card.card_button_type = "game_type"
		
		new_card["source_type"] = "card"
		new_card["type"] = "game_type"
		new_card.connect("game_select_card",_on_card_select_pressed)
		new_card.connect("mouse_focus",_on_card_select_mouse_focus)
		new_card.connect("get_info",_on_card_get_info)
		
		#new_card["card_select"].connect("pressed",_on_card_select_pressed)
		
		card_number+=1
		if card_number == hand_width:
			new_card.last_card  = true
			card_number = 0

func update_tile(payload):
	#print("update tile: ",payload)
	battlefield.update_grid_space(payload)
	#for tile in payload["tile"]:
		#print(tile)
		#battlefield.update_grid_space(tile)
	#pass

func update_victory_points(payload):
	my_victory_points.text = str(int(payload["points"]))
	enemy_victory_points.text = str(int(payload["opponent_points"]))
	#print(payload)

func _on_end_turn_button_pressed():
	end_turn.emit()

func _on_concede_button_pressed():
	concede.emit()

signal card_selected(play_info)

var selected_tile_id = ""
func _on__set_tile_id(id):
	selected_tile_id = id

#@onready var game_card_select_ui = $game_card_select_ui
#@onready var card_select = $game_card_select_ui/card_select

var picked_up : bool = false:
	set(b):
		if not b:
			position = Vector2.ZERO
			path_2d.curve.set_point_position(1,Vector2.ZERO)
			path_2d.curve.set_point_in(1,Vector2.ZERO)
			line_2d.clear_points()
		picked_up = b
		on_focus(b)
		#picked_up_changed.emit(b)


func _draw_line():
	line_2d.clear_points()
	for point in path_2d.curve.get_baked_points():
		line_2d.add_point(point+card_middle)

func on_focus(_focus):
	if _focus == true:
		focus.emit(true)
	else:
		focus.emit(false)

var focused_card = 0
var focused_type = ""
func _on_card_select_mouse_focus(_pos,_focus,_id,_focused_type):
	if not Input.is_action_pressed("M1") && click_hover == false:
		on_focus(_focus)
		if _focus:
			path_2d.curve = Curve2D.new()
			path_2d.curve.add_point(_pos)
			path_2d.curve.add_point(_pos)
			#print("card id: ",_id)
			focused_card = _id
			focused_type = _focused_type

#func _on_card_select_mouse_entered():
	#if not Input.is_action_pressed("M1") && click_hover == false:
		#on_focus(true)
#
#func _on_card_select_mouse_exited():
	#if not Input.is_action_pressed("M1") && click_hover == false:
		#on_focus(false)

func _on_card_select_pressed():
	if not picked_up:
		timer.start()
	card_selected.emit({"source_id":str(focused_card),"source_type":focused_type,"disposition_override":disposition_override})

func _on_mouse_released():
	if not timer.is_stopped():
		timer.stop()
		picked_up = true
		click_hover = true
		set_grid_buttons_visible(true)
		await mouse_released
		picked_up = false
		click_hover = false
		set_grid_buttons_visible(false)

func _on_timer_timeout():
	if not picked_up:
		picked_up = true
		await mouse_released
		picked_up = false

func _on_focus(_focus):
	if _focus == true:
		pass
		#print("FOCUSING: ",focused_card)
	else:
		focused_card = null
		focused_type = ""
		#print("UNFOCUSING: ",focused_card)

func _set_battle_field_tile(target_id,target_type,):
	#print("*******************************************************")
	#print("focused_card: ",focused_card)
	if focused_card != null:
		card_selected.emit({"source_id":str(focused_card),"source_type":focused_type,"disposition_override":disposition_override,"dest_id":target_id,"dest_type":target_type})
		disposition_override = false
		#print("source id: ",str(focused_card), ", target: ",target_id,", target type: ",target_type)
	#print(tile_id)

func _on_card_preview_mouse_focus(_pos, _focus, card_id):
	#print(_pos, _focus, card_id)
	pass

func set_grid_buttons_visible(_visible):
	for row in battlefield["grid"]:
		for column in row:
			column.grid_button.visible = _visible
			column.disable_button(true)

func choose_target(payload):
	if payload.has("valid_targets"):
		var valid_targets = str_to_var(payload["valid_targets"])
		for row in battlefield["grid"]:
			for col in row:
				col.disable_button(true)
				for target in valid_targets:
					if target["id"]==col["tile_id"] || target["id"]==col["occupant_id"]:
						#enable grid button and apply graphic
						col.disable_button(false)
						col.edit_theme_graphic(target)
						#print("valid_target: ", target["id"])
	#print(payload)
	pass

# Action Example
#{ "action": "use", "source_type": "unit", "source_id": "e5025867-c211-bbe9-a382-545baa1ad614",
#"dest_type": "unit", "dest_id": "cee40ccd-5585-8941-2953-199cc53e5465", "disposition": "unfriendly",
#"sequence": 138.0 }


func show_action(payload):
	#print(payload)
	combat_action_path.curve = Curve2D.new()
	var pos_1 = Vector2.ZERO
	if my_turn:
		pos_1 = Vector2(1528,1040)
	else:
		pos_1 = Vector2(1528,96)
	var pos_2 = Vector2.ZERO
	
	if payload["action"] == "use":
		if payload["disposition"] == "friendly":
			combat_action_line.default_color = Color.GREEN
		else:
			combat_action_line.default_color = Color.RED
			pass
	elif payload["action"] == "play":
		if payload["disposition"] == "friendly":
			combat_action_line.default_color = Color.GREEN
			pass
		else:
			combat_action_line.default_color = Color.RED
	else:
		combat_action_line.default_color = Color.WHITE
	for tile in battlefield_data:
		var grid_space = battlefield["grid"][tile["game_y"]][tile["game_x"]]
		if grid_space.tile_id == payload["dest_id"] || grid_space.occupant_id == payload["dest_id"]:
			pos_2 = grid_space.global_position + Vector2(135, 135)
		if (payload["action"] == "use" || payload["action"] == "move") && payload.has("source_id"):
			if grid_space.tile_id == payload["source_id"] || grid_space.occupant_id == payload["source_id"]:
				pos_1 = grid_space.global_position + Vector2(135, 135)
	combat_action_path.curve.add_point(pos_1)
	combat_action_path.curve.add_point(pos_1)
	combat_action_path.curve.set_point_position(1,pos_2)
	combat_action_path.curve.set_point_in(1,(Vector2(pos_2.x-500,pos_2.y)/2)*-1)
	combat_action_line.clear_points()
	for point in combat_action_path.curve.get_baked_points():
		combat_action_line.add_point(point)
	combat_action_timer.start()

func _on_combat_action_timer_timeout():
	combat_action_path.curve.set_point_position(1,Vector2.ZERO)
	combat_action_path.curve.set_point_in(1,Vector2.ZERO)
	combat_action_line.clear_points()

func _on_card_get_info(data):
	#print("*************************")
	if str(data["id"]) == card_view_id:
		card_view_id = ""
		side_tabs.current_tab = 0
		return
	get_info.emit(data)

func info_request(payload):
	card_view_card.show()
	card_view_id = str(payload["def"]["id"])
	if payload["def"]:
		card_view_card.add_details(payload["def"])
	side_tabs.current_tab = 1

#func update_card_view(card_payload):
	#card_view_card.card_name.text = card_payload["name"]
	#card_view_card.card_type.text = card_payload["subtype"].capitalize()
	#var card_effect_text = ""
	#var _discount = 0
	#if card_payload["abilities"]:
		#for ability in card_payload["abilities"]:
			#if card_payload["abilities"][ability]["name"] == "health":
				#var card_hp = card_payload["abilities"][ability]["value"]
				#card_view_card["card_health"].text = str(int(card_hp)) if card_hp > 0 else ""
			#elif card_payload["abilities"][ability]["name"] == "attack":
				#card_view_card["card_attack"].text = str(int(card_payload["abilities"][ability]["value"]))
			#elif card_payload["abilities"][ability]["name"] == "actions":
				#pass
			#elif card_payload["abilities"][ability]["name"] == "efficient":
				#_discount = card_payload["abilities"][ability]["value"]
			#elif card_payload["abilities"][ability]["value"] > 0:
				#card_effect_text += card_payload["abilities"][ability]["name"].capitalize() + "-" \
				#+ str(int(card_payload["abilities"][ability]["value"])) + "  "
	#card_view_card.card_effects.text = card_effect_text
	#card_view_card.card_price.text = str(int(card_payload["cost"]))

func _on_side_tabs_tab_clicked(tab):
	pass
	#card_view_id = ""
