extends Control

var scene_name = "game"

var stats = Stats
var utils = Utils

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

@onready var hand = $side_panel/side_tabs/Game/hand_preview/hand

@onready var my_energy = $side_panel/side_tabs/Game/player_panel/info/energy/my_energy
@onready var my_hand_size = $side_panel/side_tabs/Game/player_panel/info/cards_in_hand/my_hand_size
@onready var my_deck_size = $side_panel/side_tabs/Game/player_panel/info/cards_in_deck/my_deck_size

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
#var card_middle = Vector2(128,176)
#var card_middle = Vector2(122.4,168)
#var card_middle = Vector2(276,254)/2
var card_middle = Vector2(138,127)
var bend_factor = 0.3
var curve_min_bend_strength = 10.0
var curve_max_bend_strength = 150.0
#244.8,336
var disposition_override = false:
	set(value):
		disposition_override = value
		battlefield.change_disposition(value)
	get():
		return disposition_override

var my_turn = true:
	get():
		return my_turn
	set(value):
		my_turn = value
		side_panel_background.color = Color("3f845c") if value else Color("843f5c")
		game.color = Color("3f845c") if value else Color("843f5c")

signal mouse_released
#signal picked_up_changed(picked)
signal focus(_focus)

var previewed_grid_spaces: Array = []
@onready var card_popup_layer := $card_popup_layer
@onready var my_card_popup_anchor := $card_popup_layer/my_card_popup_anchor
@onready var opponent_card_popup_anchor := $card_popup_layer/opponent_card_popup_anchor

var pending_effects_from_selected_target: Array = []
var effect_popup_queue: Array = []
var effect_popup_playing := false
var last_known_unit_positions := {}
var known_unit_abilities := {}
var recently_shown_effect_keys := {}

var my_avatar_id := ""
var active_card_popups: Array = []
var known_occupants := {}
var shown_played_card_popups := {}

func _ready():
	set_color_backgrounds()
	path_2d.curve = Curve2D.new()
	path_2d.curve.add_point(global_position)
	#path_2d.curve.add_point(global_position)
	path_2d.curve.bake_interval = 50

@warning_ignore("unused_parameter")
func _process(delta):
	if picked_up:
		var dir = get_global_mouse_position()-start_curve_point
		var dist = dir.length()
		if dist < 1.0:
			dist = 1.0
		var dir_norm = dir / dist
		var normal = dir_norm.orthogonal()
		if normal.y > 0.0:
			normal = -normal
		var bend_strength = clamp(dist * bend_factor, curve_min_bend_strength, curve_max_bend_strength)
		var out0 = dir_norm * (dist * 0.25) + normal * bend_strength
		var in1 = -dir_norm * (dist * 0.25) + normal * bend_strength
		path_2d.curve = Curve2D.new()
		path_2d.curve.clear_points()
		path_2d.curve.add_point(start_curve_point,Vector2.ZERO, out0)
		path_2d.curve.add_point(get_global_mouse_position(),in1,Vector2.ZERO)
		#path_2d.curve.set_point_position(1,get_local_mouse_position())
		#path_2d.curve.set_point_in(1,(Vector2(get_local_mouse_position().x-1000,get_local_mouse_position().y)/2)*-1)
		#path_2d.curve.set_point_in(1,(Vector2(get_local_mouse_position().x,get_local_mouse_position().y)))
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
		#grid_space["card"]["card_select"].connect("pressed",_on_card_select_pressed)
		#grid_space["card"].connect("mouse_focus",_on_card_select_mouse_focus)
		#grid_space.connect("get_info",_on_card_get_info)
		grid_space["unit_select_button"].connect("pressed",_on_card_select_pressed)
		grid_space.connect("mouse_focus",_on_card_select_mouse_focus)
		if not grid_space.target_preview_started.is_connected(_on_target_preview_started):
			grid_space.target_preview_started.connect(_on_target_preview_started)
		if not grid_space.target_preview_ended.is_connected(_on_target_preview_ended):
			grid_space.target_preview_ended.connect(_on_target_preview_ended)
		

@warning_ignore("unused_parameter")
func quit_game(payload):
	card_view_card.hide()
	card_view_id = ""
	shown_played_card_popups.clear()
	known_occupants.clear()
	for tile in battlefield_data:
		#var grid_space = battlefield["grid"][tile["game_y"]][tile["game_x"]]
		var grid_space = battlefield["grid"][tile["display_y"]][tile["display_x"]]
		
		
		if grid_space.is_connected("tile_chosen",_set_battle_field_tile):
			grid_space.disconnect("tile_chosen",_set_battle_field_tile)


		#if grid_space["card"]["card_select"].is_connected("pressed",_on_card_select_pressed):
			#grid_space["card"]["card_select"].disconnect("pressed",_on_card_select_pressed)
		
		if grid_space["unit_select_button"].is_connected("pressed",_on_card_select_pressed):
			grid_space["unit_select_button"].disconnect("pressed",_on_card_select_pressed)

		#if grid_space["card"].is_connected("mouse_focus",_on_card_select_mouse_focus):
			#grid_space["card"].disconnect("mouse_focus",_on_card_select_mouse_focus)
		
		if grid_space.is_connected("mouse_focus",_on_card_select_mouse_focus):
			grid_space.disconnect("mouse_focus",_on_card_select_mouse_focus)

func update_unit(payload):
	var unit = payload["unit"]
	var unit_id := str(unit["id"])
	_queue_unit_stat_change_popups(unit)
	known_unit_abilities[unit_id] = unit["abilities"].duplicate(true)
	if str(unit["id"]) == card_view_id:
		card_view_card.add_details(unit, true)
	battlefield.update_unit(payload)

#func update_unit(payload):
	##print("unit selected: ", card_view_id)
	##print("update unit: ",payload)
	##print("here")
	##print(str(payload["unit"]["id"]),":",card_view_id)
	#if str(payload["unit"]["id"]) == card_view_id:
		#card_view_card.add_details(payload["unit"],true)
		##update_card_view(payload["unit"])
	##print("update unit: ",payload["unit"]["x"])
	#battlefield.update_unit(payload)
	#pass

func update_turn(payload):
	if payload.has("my_avatar_id"):
		my_avatar_id = str(payload["my_avatar_id"])
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

#func add_combat_log(payload):
	##utils.j_print(payload)
	#var new_log = preload("res://items/game_log_label.tscn").instantiate()
	#first_log.add_sibling(new_log)
	#new_log.text = payload["statement"]
	##print("add combat log: ")
	##print("add combat log: ",payload["arguments"])
	##print("argument size: ",payload["arguments"].size())
	##for item in payload["arguments"]:
		##print(item)

func add_combat_log(payload):
	var new_log = preload("res://items/game_log_label.tscn").instantiate()
	first_log.add_sibling(new_log)
	new_log.text = _format_combat_log_statement(payload)

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
			#row_node.alignment = BoxContainer.ALIGNMENT_CENTER
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

#func update_tile(payload):
	##print("update tile: ",payload)
	#battlefield.update_grid_space(payload)
	#
	#if payload["action"] == "play":
		#if payload.has("card"):
			#show_played_card_popup(payload["card"], is_card_played_by_me(payload))
		#elif payload.has("unit") and payload["unit"].has("card"):
			#show_played_card_popup(payload["unit"]["card"], is_card_played_by_me(payload))
	##for tile in payload["tile"]:
		##print(tile)
		##battlefield.update_grid_space(tile)
	##pass

func update_tile(payload):
	var tile = payload["tile"]
	if tile["occupied"] and tile.has("occupant"):
		var tile_id = str(tile["id"])
		var new_occupant_id = str(tile["occupant"]["id"])
		last_known_unit_positions[new_occupant_id] = {
			"global_position": _get_tile_global_position_by_tile_id(tile_id),
			"tile_id": tile_id
		}
		var is_new_unit_on_tile := false
		if not known_occupants.has(tile_id):
			is_new_unit_on_tile = true
		elif known_occupants[tile_id] != new_occupant_id:
			is_new_unit_on_tile = true
		known_occupants[tile_id] = new_occupant_id
		if is_new_unit_on_tile:
			var popup_unit_id := str(tile["occupant"]["id"])
			if not shown_played_card_popups.has(popup_unit_id):
				shown_played_card_popups[popup_unit_id] = true
				show_played_card_popup(tile["occupant"], is_occupant_mine(tile["occupant"]))
	elif tile.has("id"):
		known_occupants.erase(str(tile["id"]))
	battlefield.update_grid_space(payload)


func _on_end_turn_button_pressed():
	end_turn.emit()

func _on_concede_button_pressed():
	concede.emit()

signal card_selected(play_info)

var selected_tile_id = ""
func _on__set_tile_id(id):
	selected_tile_id = id

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
		line_2d.add_point(point)

func on_focus(_focus):
	if _focus == true:
		focus.emit(true)
	else:
		focus.emit(false)

var start_curve_point
var focused_card = 0
var focused_type = ""
func _on_card_select_mouse_focus(_pos,_focus,_id,_focused_type):
	if not Input.is_action_pressed("M1") && click_hover == false:
		on_focus(_focus)
		if _focus:
			start_curve_point = _pos
			focused_card = _id
			focused_type = _focused_type

func _on_card_select_pressed():
	#print("source_id: ", focused_card)
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

func _set_battle_field_tile(target_id, target_type):
	if focused_card != null:
		_capture_pending_effects_for_target(target_id)
		card_selected.emit({
			"source_id": str(focused_card),
			"source_type": focused_type,
			"disposition_override": disposition_override,
			"dest_id": target_id,
			"dest_type": target_type
		})
		disposition_override = false

func _capture_pending_effects_for_target(target_id) -> void:
	pending_effects_from_selected_target.clear()
	for row in battlefield["grid"]:
		for col in row:
			if str(col.tile_id) == str(target_id) or str(col.occupant_id) == str(target_id):
				if col.has_method("get") and col.get("target_payload") != null:
					var target_payload = col.get("target_payload")
					if target_payload is Dictionary and target_payload.has("affected"):
						pending_effects_from_selected_target = target_payload["affected"].duplicate(true)
				return

func _play_pending_effects_after_action_line() -> void:
	if pending_effects_from_selected_target.is_empty():
		return
	var effects_to_play := pending_effects_from_selected_target.duplicate(true)
	pending_effects_from_selected_target.clear()
	await get_tree().create_timer(0.25).timeout
	for affected in effects_to_play:
		_queue_affected_popup(affected)
	_play_effect_popup_queue()

#func _queue_affected_popup(affected: Dictionary) -> void:
	#var affected_id := str(affected.get("id", ""))
	#var popup_position := _find_effect_popup_position(affected)
	#for change in affected.get("changes", []):
		#var text := _get_change_popup_text(change)
		#if text != "":
			#effect_popup_queue.append({
				#"position": popup_position,
				#"text": text,
				#"value": float(change.get("value", 0))
			#})

func _queue_affected_popup(affected: Dictionary) -> void:
	var affected_id := str(affected.get("id", ""))
	var popup_position := _find_effect_popup_position(affected)
	for change in affected.get("changes", []):
		var text := _get_change_popup_text(change)
		if text == "":
			continue
		var effect_key := affected_id + ":" + str(change.get("name", ""))
		if recently_shown_effect_keys.has(effect_key):
			continue
		recently_shown_effect_keys[effect_key] = true
		_clear_recent_effect_key_later(effect_key)
		effect_popup_queue.append({
			"position": popup_position,
			"text": text,
			"value": float(change.get("value", 0))
		})

func _play_effect_popup_queue() -> void:
	if effect_popup_playing:
		return
	effect_popup_playing = true
	while effect_popup_queue.size() > 0:
		var effect_data = effect_popup_queue.pop_front()
		_show_single_effect_popup(effect_data)
		await get_tree().create_timer(0.3).timeout
	effect_popup_playing = false

func _show_single_effect_popup(effect_data: Dictionary) -> void:
	var popup_position: Vector2 = effect_data["position"]
	var label := Label.new()
	card_popup_layer.add_child(label)
	label.text = str(effect_data["text"])
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 42)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 999
	label.global_position = popup_position
	label.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.12)
	tween.tween_interval(0.7)
	var move_tween := create_tween()
	move_tween.tween_property(
		label,
		"global_position",
		label.global_position + Vector2(0, -70),
		1.0
	)
	tween.tween_property(label, "modulate:a", 0.0, 0.4)
	await tween.finished
	if is_instance_valid(label):
		label.queue_free()

func _get_change_popup_text(change: Dictionary) -> String:
	var change_name := str(change.get("name", ""))
	var value := float(change.get("value", 0))
	if is_equal_approx(value, 0.0):
		return ""
	var sign := "+" if value > 0 else ""
	match change_name:
		"health":
			return "%s%s HP" % [sign, _format_effect_number(value)]
		"actions":
			return ""
		"strength":
			return "%s%s ATK" % [sign, _format_effect_number(value)]
		_:
			return "%s%s %s" % [sign, _format_effect_number(value), change_name.capitalize()]

func _format_effect_number(value: float) -> String:
	if is_equal_approx(value, int(value)):
		return str(int(value))
	return str(value)


func _on_card_preview_mouse_focus(_pos, _focus, card_id):
	#print(_pos, _focus, card_id)
	pass

func set_grid_buttons_visible(_visible):
	for row in battlefield["grid"]:
		for column in row:
			column.unit_button.visible = _visible
			column.disable_button(true)

#func choose_target(payload):
	#if payload.has("valid_targets"):
		#var valid_targets = str_to_var(payload["valid_targets"])
		#for row in battlefield["grid"]:
			#for col in row:
				#col.disable_button(true)
				#for target in valid_targets:
					#if target["id"]==col["tile_id"]:
						#col.target_type = "tile"
					#if target["id"]==col["occupant_id"]:
						#col.target_type = "unit"
					#if target["id"]==col["tile_id"] || target["id"]==col["occupant_id"]:
						##enable grid button and apply graphic
						#col.disable_button(false)
						#col.edit_theme_graphic(target)
						##print("valid_target: ", target["id"])
	##print(payload)
	#pass

# Action Example
#{ "action": "use", "source_type": "unit", "source_id": "e5025867-c211-bbe9-a382-545baa1ad614",
#"dest_type": "unit", "dest_id": "cee40ccd-5585-8941-2953-199cc53e5465", "disposition": "unfriendly",
#"sequence": 138.0 }

func choose_target(payload):
	clear_target_preview()
	if payload.has("valid_targets"):
		var valid_targets = str_to_var(payload["valid_targets"])
		for row in battlefield["grid"]:
			for col in row:
				col.disable_button(true)
		for target in valid_targets:
			for row in battlefield["grid"]:
				for col in row:
					if target["id"] == col["tile_id"]:
						col.target_type = "tile"
					if target["id"] == col["occupant_id"]:
						col.target_type = "unit"
					if target["id"] == col["tile_id"] or target["id"] == col["occupant_id"]:
						col.disable_button(false)
						col.edit_theme_graphic(target)
						col.set_target_payload(target)

func _on_target_preview_started(target_payload: Dictionary) -> void:
	clear_target_preview()

	for affected in target_payload.get("affected", []):
		var affected_id := str(affected.get("id", ""))

		for row in battlefield["grid"]:
			for col in row:
				if affected_id == str(col.occupant_id) or affected_id == str(col.tile_id):
					col.preview_affected_result(affected)
					previewed_grid_spaces.append(col)


func _on_target_preview_ended() -> void:
	clear_target_preview()

func clear_target_preview() -> void:
	for col in previewed_grid_spaces:
		if is_instance_valid(col):
			col.clear_affected_preview()
	previewed_grid_spaces.clear()

func show_action(payload):
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
			pos_2 = grid_space.global_position + Vector2(127, 127)
		if (payload["action"] == "use" || payload["action"] == "move") && payload.has("source_id"):
			if grid_space.tile_id == payload["source_id"] || grid_space.occupant_id == payload["source_id"]:
				pos_1 = grid_space.global_position + Vector2(127, 127)
	combat_action_path.curve.add_point(pos_1)
	combat_action_path.curve.add_point(pos_1)
	combat_action_path.curve.set_point_position(1,pos_2)
	combat_action_path.curve.set_point_in(1,(Vector2(pos_2.x-500,pos_2.y)/2)*-1)
	combat_action_line.clear_points()
	for point in combat_action_path.curve.get_baked_points():
		combat_action_line.add_point(point)
	combat_action_timer.start()
	if payload.has("affected"):
		_play_affected_effects(payload["affected"])
	elif payload["action"] == "play" or payload["action"] == "use":
		_play_pending_effects_after_action_line()

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
	#print(payload)
	if payload["def"]:
		card_view_card.add_details(payload["def"])
	side_tabs.current_tab = 1

func _on_side_tabs_tab_clicked(tab):
	pass
	#card_view_id = ""

func show_played_card_popup(card_data: Dictionary, played_by_me: bool) -> void:
	if card_data.is_empty():
		return
	var subtype := str(card_data.get("subtype", "")).to_lower()
	if subtype == "" and card_data.has("card"):
		subtype = str(card_data["card"].get("subtype", "")).to_lower()
	if subtype == "trap" or subtype == "avatar":
		return
	var anchor = my_card_popup_anchor if played_by_me else opponent_card_popup_anchor
	var popup_card = CARD_SCENE.instantiate()
	anchor.add_child(popup_card)
	popup_card.define_scale(4)
	popup_card.add_details(card_data, card_data.has("card"))
	popup_card.position = Vector2.ZERO
	popup_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_make_control_tree_ignore_mouse(popup_card)
	popup_card.modulate.a = 0.0
	active_card_popups.append(popup_card)
	var tween := create_tween()
	tween.set_parallel(false)
	tween.tween_property(popup_card, "modulate:a", 1.0, 0.2)
	tween.tween_interval(1.4)
	tween.tween_property(popup_card, "modulate:a", 0.0, 0.35)
	tween.finished.connect(func():
		active_card_popups.erase(popup_card)
		if is_instance_valid(popup_card):
			# Hide it first so the HBox reflow is not visually obvious.
			popup_card.visible = false
			# Wait briefly, then remove it after it is invisible.
			await get_tree().create_timer(0.15).timeout
			if is_instance_valid(popup_card):
				popup_card.queue_free()
	)

func is_card_played_by_me(payload: Dictionary) -> bool:
	if payload.has("player_id") and payload.has("my_player_id"):
		return str(payload["player_id"]) == str(payload["my_player_id"])
	if payload.has("avatar_id") and payload.has("my_avatar_id"):
		return str(payload["avatar_id"]) == str(payload["my_avatar_id"])
	if payload.has("owner_id") and payload.has("my_owner_id"):
		return str(payload["owner_id"]) == str(payload["my_owner_id"])
	return my_turn

func is_occupant_mine(occupant: Dictionary) -> bool:
	if my_avatar_id == "":
		return my_turn
	if occupant.has("owner") and occupant["owner"] is Dictionary:
		if str(occupant["owner"].get("id", "")) == my_avatar_id:
			return true
	if str(occupant.get("owner_id", "")) == my_avatar_id:
		return true
	if str(occupant.get("avatar_id", "")) == my_avatar_id:
		return true
	if occupant.has("card") and occupant["card"] is Dictionary:
		var card = occupant["card"]
		if str(card.get("owner_id", "")) == my_avatar_id:
			return true
		if str(card.get("avatar_id", "")) == my_avatar_id:
			return true
	return false

func _make_control_tree_ignore_mouse(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_make_control_tree_ignore_mouse(child)

func _get_tile_global_position_by_tile_id(tile_id: String) -> Vector2:
	for row in battlefield["grid"]:
		for col in row:
			if str(col.tile_id) == str(tile_id):
				return col.global_position
	return Vector2.ZERO

func _play_affected_effects(affected_list) -> void:
	if affected_list is String:
		affected_list = str_to_var(affected_list)
	if not affected_list is Array:
		return
	await get_tree().create_timer(0.25).timeout
	for affected in affected_list:
		_queue_affected_popup(affected)
	_play_effect_popup_queue()

func _find_effect_popup_position(affected: Dictionary) -> Vector2:
	var affected_id := str(affected.get("id", ""))
	for row in battlefield["grid"]:
		for col in row:
			if affected_id == str(col.occupant_id) or affected_id == str(col.tile_id):
				return col.global_position + Vector2(80, 60)
	if last_known_unit_positions.has(affected_id):
		return last_known_unit_positions[affected_id]["global_position"] + Vector2(80, 60)
	if affected.has("x") and affected.has("y"):
		for row in battlefield["grid"]:
			for col in row:
				if int(col.get("x")) == int(affected["x"]) and int(col.get("y")) == int(affected["y"]):
					return col.global_position + Vector2(80, 60)
	return Vector2(960, 540)

func _queue_unit_stat_change_popups(unit: Dictionary) -> void:
	var unit_id := str(unit["id"])
	if not known_unit_abilities.has(unit_id):
		known_unit_abilities[unit_id] = unit["abilities"].duplicate(true)
		return
	var old_abilities: Dictionary = known_unit_abilities[unit_id]
	var new_abilities: Dictionary = unit["abilities"]
	for ability_key in new_abilities:
		if not old_abilities.has(ability_key):
			continue
		var old_ability = old_abilities[ability_key]
		var new_ability = new_abilities[ability_key]
		var old_value := float(old_ability.get("value", 0))
		var new_value := float(new_ability.get("value", 0))
		var diff := new_value - old_value
		if is_equal_approx(diff, 0.0):
			continue
		var fake_change := {
			"name": str(new_ability.get("name", "")),
			"value": diff
		}
		_queue_affected_popup({
			"id": unit_id,
			"x": unit.get("x", null),
			"y": unit.get("y", null),
			"changes": [fake_change]
		})
	_play_effect_popup_queue()

func _format_combat_log_statement(payload: Dictionary) -> String:
	var statement := str(payload.get("statement", ""))
	if not payload.has("arguments"):
		return statement
	var args: Array = payload["arguments"]
	for i in range(args.size()):
		var placeholder := "$" + str(i + 1)
		var replacement := _get_combat_log_arg_name(args[i])
		statement = statement.replace(placeholder, replacement)
	return statement

func _get_combat_log_arg_name(arg) -> String:
	if arg is Dictionary:
		if arg.has("name"):
			return str(arg["name"])
		if arg.has("base_name"):
			return str(arg["base_name"])
		if arg.has("card") and arg["card"] is Dictionary:
			if arg["card"].has("name"):
				return str(arg["card"]["name"])
	return str(arg)

func _clear_recent_effect_key_later(effect_key: String) -> void:
	await get_tree().create_timer(2.0).timeout
	recently_shown_effect_keys.erase(effect_key)
