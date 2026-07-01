extends Control

var scene_name = "game"

var stats = Stats
var sounds = Sounds
var utils = Utils

#const card_preview = preload("res://items/card_preview.tscn")
const CARD_SCENE = preload("res://items/card.tscn")
const LOG_CARD_ENTRY_SCENE = preload("res://items/log_card_entry.tscn")
const LOG_EVENT_ICONS := {
	"draw": preload("res://assets/art/battlefield_icons/draw.png"),
	"play_unit": preload("res://assets/art/battlefield_icons/play_unit.png"),
	"play_trap": preload("res://assets/art/battlefield_icons/play_trap.png"),
	"died": preload("res://assets/art/battlefield_icons/unit_died.png"),
	"attacks": preload("res://assets/art/battlefield_icons/attack_unit.png"),
}

signal end_turn
signal concede
signal get_info(data)

@onready var side_panel_background = $side_panel/side_panel_background
@onready var game = $side_panel/side_tabs/Game
#@onready var card_view = $"side_panel/side_tabs/Card View"
@onready var log_visuals = $side_panel/side_tabs/Log

@onready var battlefield = $battlefield

@onready var side_tabs = $side_panel/side_tabs

#@onready var card_view_card = $"side_panel/side_tabs/Card View/card_view_card"

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

var known_units := {}
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

var unread_log_count := 0
var log_tab_index := 1
var last_logged_turn_avatar_id := ""

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
var combat_log_card_refs := {}
var combat_log_hover_token := 0

var hover_card_popup = null
var hover_card_popup_unit_id := ""
var hover_card_requested_unit_id := ""
var hover_card_requested_pos := Vector2.ZERO
var hover_card_delay_seconds := 0.35
var hover_hide_delay_seconds := 0.15
var hover_token := 0
var hover_source_rect := Rect2()
var hover_unit_mouse_over := false
var hover_popup_mouse_over := false
var hover_card_pinned := false
var hover_card_pinned_unit_id := ""
var log_card_hover_token := 0
var recent_tile_popup_positions := {}

var my_avatar_id := ""
var active_card_popups: Array = []
var known_occupants := {}
var shown_played_card_popups := {}

var last_active_avatar_id_for_sound := ""
var has_received_first_turn_update := false

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
	#card_view.color = stats.background_color
	log_visuals.color = stats.background_color

func join_game(payload):
	sounds.play_music("battle_music",1,-20)
	await battlefield.create_grid(payload["board"]["cols"],payload["board"]["rows"])
	#print("join game: ",payload)
	battlefield_data = payload["board"]["tiles"]
	for tile in battlefield_data:
		#print(tile)
		battlefield.set_grid_space(tile)
		if tile.get("occupied", false) and tile.has("occupant"):
			var start_occupant_id := str(tile["occupant"]["id"])
			known_units[start_occupant_id] = tile["occupant"].duplicate(true)

			known_occupants[str(tile["id"])] = start_occupant_id
			shown_played_card_popups[start_occupant_id] = true
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
		if not grid_space.unit_hover_started.is_connected(_on_unit_hover_started):
			grid_space.unit_hover_started.connect(_on_unit_hover_started)
		if not grid_space.unit_hover_ended.is_connected(_on_unit_hover_ended):
			grid_space.unit_hover_ended.connect(_on_unit_hover_ended)
		if not grid_space.target_preview_started.is_connected(_on_target_preview_started):
			grid_space.target_preview_started.connect(_on_target_preview_started)
		if not grid_space.target_preview_ended.is_connected(_on_target_preview_ended):
			grid_space.target_preview_ended.connect(_on_target_preview_ended)
		if not grid_space.unit_right_clicked.is_connected(_on_unit_right_clicked):
			grid_space.unit_right_clicked.connect(_on_unit_right_clicked)

@warning_ignore("unused_parameter")
func quit_game(payload):
	#card_view_card.hide()
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
	known_units[str(payload["unit"]["id"])] = payload["unit"].duplicate(true)
	var unit = payload["unit"]
	var unit_id := str(unit["id"])
	if recent_tile_popup_positions.has(unit_id):
		_queue_unit_stat_change_popups(unit, recent_tile_popup_positions[unit_id])
	else:
		_queue_unit_stat_change_popups(unit)
	known_unit_abilities[unit_id] = unit["abilities"].duplicate(true)
	#if str(unit["id"]) == card_view_id:
		#card_view_card.add_details(unit, true)
	battlefield.update_unit(payload)

func update_turn(payload):
	if payload.has("my_avatar_id"):
		my_avatar_id = str(payload["my_avatar_id"])
	if payload["active_avatar_id"]:
		var active_avatar_id := str(payload["active_avatar_id"])
		if active_avatar_id == my_avatar_id:
			my_turn = true
			end_turn_button.text = "End Turn"
			end_turn_button.disabled = false
		else:
			my_turn = false
			end_turn_button.text = "Opponent's Turn"
			end_turn_button.disabled = true
		_play_turn_change_sound_if_needed(payload)
		_add_turn_log_separator_if_needed(active_avatar_id)
	if payload.has("ticks_remaining"):
		turn_timer_count.text = str(int(payload["ticks_remaining"]))
		turn_timer_right.max_value = payload["ticks_in_turn"]
		turn_timer_right.value = payload["ticks_remaining"]
		turn_timer_left.max_value = payload["ticks_in_turn"]
		turn_timer_left.value = payload["ticks_remaining"]

func _play_turn_change_sound_if_needed(payload: Dictionary) -> void:
	if not payload.has("active_avatar_id"):
		return
	var active_avatar_id := str(payload["active_avatar_id"])
	if active_avatar_id == "":
		return
	# First turn update is just sync/setup. Do not play a sound.
	if not has_received_first_turn_update:
		has_received_first_turn_update = true
		last_active_avatar_id_for_sound = active_avatar_id
		return
	# Same active avatar means same turn. Do not replay sound.
	if active_avatar_id == last_active_avatar_id_for_sound:
		return
	last_active_avatar_id_for_sound = active_avatar_id
	if active_avatar_id == my_avatar_id:
		play_game_sound("start_turn")
	else:
		play_game_sound("end_turn")

func _add_turn_log_separator_if_needed(active_avatar_id: String) -> void:
	if active_avatar_id == "":
		return
	if last_logged_turn_avatar_id == active_avatar_id:
		return
	last_logged_turn_avatar_id = active_avatar_id
	var separator := Label.new()
	first_log.add_sibling(separator)
	separator.text = "— Your Turn —" if active_avatar_id == my_avatar_id else "— Opponent's Turn —"
	separator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	separator.add_theme_font_size_override("font_size", 18)
	separator.add_theme_color_override("font_color", Color.WHITE)
	separator.custom_minimum_size = Vector2(0, 32)

func add_combat_log(payload):
	#print("************************************")
	#utils.j_print(payload)
	var panel := PanelContainer.new()
	first_log.add_sibling(panel)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_log_panel_style(is_log_from_me(payload)))
	var row := HBoxContainer.new()
	panel.add_child(row)
	row.custom_minimum_size = Vector2(0, 72)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 8)
	_add_log_event_icon(row, _get_log_icon_key(payload))
	var text := _format_combat_log_statement(payload)
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 24)
	row.add_child(label)
	_add_combat_log_card_entries(row, payload)
	if side_tabs.current_tab != log_tab_index:
		unread_log_count += 1
		_update_log_tab_title()

func is_log_from_me(payload: Dictionary) -> bool:
	if payload.has("avatar_id") and my_avatar_id != "":
		return str(payload["avatar_id"]) == my_avatar_id
	if payload.has("source") and payload["source"] is Dictionary:
		var source = payload["source"]
		if source.has("owner_id"):
			return str(source["owner_id"]) == my_avatar_id
		if source.has("avatar_id"):
			return str(source["avatar_id"]) == my_avatar_id
	return my_turn

func _make_log_panel_style(from_me: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("2f6f4f88") if from_me else Color("6f2f4f88")
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style

func _update_log_tab_title() -> void:
	if unread_log_count > 0:
		side_tabs.set_tab_title(log_tab_index, "Log (" + str(unread_log_count) + ")")
	else:
		side_tabs.set_tab_title(log_tab_index, "Log")

func _build_combat_log_row(row: HBoxContainer, payload: Dictionary) -> String:
	var statement := str(payload.get("statement", ""))
	if not payload.has("arguments"):
		return statement
	var args: Array = payload["arguments"]
	for i in range(args.size()):
		var placeholder := "$" + str(i + 1)
		var arg = args[i]
		if arg is Dictionary and _combat_log_arg_has_card(arg):
			var card_name := _get_combat_log_arg_name(arg)
			statement = statement.replace(placeholder, card_name)
			var entry = LOG_CARD_ENTRY_SCENE.instantiate()
			row.add_child(entry)
			entry.set_card_data(arg)
			entry.card_entry_clicked.connect(_on_log_card_entry_clicked)
		else:
			statement = statement.replace(placeholder, _get_combat_log_arg_name(arg))
	return statement

func _add_combat_log_card_entries(row: HBoxContainer, payload: Dictionary) -> void:
	if not payload.has("arguments"):
		return
	for arg in payload["arguments"]:
		if arg is Dictionary and _combat_log_arg_has_card(arg):
			var entry = LOG_CARD_ENTRY_SCENE.instantiate()
			entry.custom_minimum_size = Vector2(48, 48)
			entry.size_flags_horizontal = Control.SIZE_SHRINK_END
			row.add_child(entry)
			entry.set_card_data(arg)
			entry.card_entry_clicked.connect(_on_log_card_entry_clicked)
			entry.card_entry_hover_started.connect(_on_log_card_entry_hover_started)
			entry.card_entry_hover_ended.connect(_on_log_card_entry_hover_ended)
			entry.card_entry_right_clicked.connect(_on_log_card_entry_right_clicked)

func _on_log_card_entry_clicked(card_data: Dictionary) -> void:
	_on_log_card_entry_right_clicked(card_data)

#func _on_log_card_entry_clicked(card_data: Dictionary) -> void:
	#clear_all_hover_card_popups()
	#var popup_card = CARD_SCENE.instantiate()
	#popup_card.add_to_group("hover_card_popups")
	#card_popup_layer.add_child(popup_card)
	#hover_card_popup = popup_card
	#hover_card_popup_unit_id = str(card_data.get("id", Time.get_ticks_msec()))
	#hover_card_pinned = true
	#hover_card_pinned_unit_id = hover_card_popup_unit_id
	#popup_card.define_scale(4)
	#popup_card.add_details(card_data, card_data.has("card"))
	#popup_card.global_position = log_visuals.global_position + Vector2(-360, 40)
	#popup_card.z_index = 1000
	#_connect_right_click_close_to_tree(popup_card)

func _get_first_combat_log_card_ref(payload: Dictionary) -> String:
	if not payload.has("arguments"):
		return ""
	var args: Array = payload["arguments"]
	for i in range(args.size()):
		var arg = args[i]
		if arg is Dictionary and _combat_log_arg_has_card(arg):
			return "combat_log_card_" + str(payload.get("sequence", Time.get_ticks_msec())) + "_" + str(i)
	return ""

func _on_combat_log_line_hover_started(ref_id: String) -> void:
	if not combat_log_card_refs.has(ref_id):
		return
	combat_log_hover_token += 1
	show_hover_combat_log_card_popup(ref_id)

func _format_combat_log_statement_clickable(payload: Dictionary) -> String:
	var statement := str(payload.get("statement", ""))
	if not payload.has("arguments"):
		return statement
	var args: Array = payload["arguments"]
	for i in range(args.size()):
		var placeholder := "$" + str(i + 1)
		var arg = args[i]
		var replacement := _get_combat_log_arg_name(arg)
		if arg is Dictionary and _combat_log_arg_has_card(arg):
			var ref_id := "combat_log_card_" + str(payload.get("sequence", Time.get_ticks_msec())) + "_" + str(i)
			combat_log_card_refs[ref_id] = arg.duplicate(true)
			replacement = "[url=" + ref_id + "]" + replacement + "[/url]"
		statement = statement.replace(placeholder, replacement)
	return statement

func _combat_log_arg_has_card(arg: Dictionary) -> bool:
	return arg.has("card") or arg.get("type", "") == "card" or arg.get("type", "") == "unit"

func _on_combat_log_meta_hover_started(meta) -> void:
	var ref_id := str(meta)
	if not combat_log_card_refs.has(ref_id):
		return
	combat_log_hover_token += 1
	show_hover_combat_log_card_popup(ref_id)

func _on_combat_log_meta_hover_ended(meta) -> void:
	var ref_id := str(meta)
	var my_token := combat_log_hover_token
	await get_tree().create_timer(0.15).timeout
	if my_token != combat_log_hover_token:
		return
	if ref_id != hover_card_popup_unit_id:
		return
	if hover_card_pinned:
		return
	hide_hover_unit_card_popup()

func _on_combat_log_mouse_exited() -> void:
	combat_log_hover_token += 1
	await get_tree().create_timer(0.12).timeout
	if hover_card_pinned:
		return
	hide_hover_unit_card_popup()

func _on_combat_log_meta_clicked(meta) -> void:
	var ref_id := str(meta)
	if not combat_log_card_refs.has(ref_id):
		return
	if hover_card_pinned and hover_card_pinned_unit_id == ref_id:
		clear_all_hover_card_popups()
		return
	clear_all_hover_card_popups()
	hover_card_pinned = true
	hover_card_pinned_unit_id = ref_id
	show_hover_combat_log_card_popup(ref_id)

func show_hover_combat_log_card_popup(ref_id: String) -> void:
	if hover_card_popup_unit_id == ref_id and is_instance_valid(hover_card_popup):
		return
	if not combat_log_card_refs.has(ref_id):
		return

	#clear_all_hover_card_popups()

	var popup_card = CARD_SCENE.instantiate()
	popup_card.add_to_group("hover_card_popups")
	card_popup_layer.add_child(popup_card)

	hover_card_popup = popup_card
	hover_card_popup_unit_id = ref_id

	var card_data = combat_log_card_refs[ref_id]
	popup_card.define_scale(4)
	popup_card.add_details(card_data, card_data.has("card"))

	_make_control_tree_ignore_mouse(popup_card)

	popup_card.z_index = 1000
	popup_card.modulate.a = 1.0
	popup_card.global_position = log_visuals.global_position + Vector2(-360, 40)

func update_energy(payload):
	my_energy.text = str(int(payload["energy"]))
	enemy_energy.text = str(int(payload["opponent_energy"]))

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
		#new_card.connect("get_info",_on_card_get_info)
		#new_card["card_select"].connect("pressed",_on_card_select_pressed)
		card_number+=1
		if card_number == hand_width:
			new_card.last_card  = true
			card_number = 0

func update_tile(payload):
	var tile = payload["tile"]
	if tile["occupied"] and tile.has("occupant"):
		var tile_id := str(tile["id"])
		var occupant = tile["occupant"]
		var occupant_id := str(occupant["id"])
		var tile_popup_position := _get_tile_popup_position_from_payload(tile)
		recent_tile_popup_positions[occupant_id] = tile_popup_position
		_clear_recent_tile_popup_position_later(occupant_id)
		last_known_unit_positions[occupant_id] = {
			"global_position": _get_tile_global_position_by_tile_id(tile_id),
			"tile_id": tile_id
		}
		_queue_unit_stat_change_popups(occupant, tile_popup_position)
		known_unit_abilities[occupant_id] = occupant["abilities"].duplicate(true)
		known_units[occupant_id] = occupant.duplicate(true)
		var new_occupant_id = occupant_id
		var is_new_unit_on_tile := false
		if not known_occupants.has(tile_id):
			is_new_unit_on_tile = true
		elif known_occupants[tile_id] != new_occupant_id:
			is_new_unit_on_tile = true
		known_occupants[tile_id] = new_occupant_id
		if is_new_unit_on_tile:
			var popup_unit_id := str(tile["occupant"]["id"])
			
			var subtype = str(tile["occupant"].get("subtype","")).to_lower()
			
			if not shown_played_card_popups.has(popup_unit_id):
				shown_played_card_popups[popup_unit_id] = true
				
				match subtype:
					"trap":
						play_game_sound("play_trap")
					"potion":
						play_game_sound("play_potion")
					"unit":
						play_game_sound("play_unit")
					_:
						play_game_sound("draw_card")
				
				show_played_card_popup(tile["occupant"], is_occupant_mine(tile["occupant"]))
				_animate_unit_played(tile_id)
	elif tile.has("id"):
		known_occupants.erase(str(tile["id"]))
	battlefield.update_grid_space(payload)

func _clear_recent_tile_popup_position_later(unit_id: String) -> void:
	await get_tree().create_timer(0.75).timeout
	recent_tile_popup_positions.erase(unit_id)

func _on_end_turn_button_pressed():
	#play_game_sound("end_turn")
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

func _on_card_select_mouse_focus(_pos, _focus, _id, _focused_type):
	if Input.is_action_pressed("M1") or click_hover:
		return

	on_focus(_focus)

	if _focus:
		start_curve_point = _pos
		focused_card = _id
		focused_type = _focused_type
	else:
		focused_card = null
		focused_type = ""

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
						var effects = target_payload["affected"].duplicate(true)
						var popup_pos = col.global_position + Vector2(80, 60)
						for affected in effects:
							if affected is Dictionary:
								affected["popup_position"] = popup_pos
						pending_effects_from_selected_target = effects
				return

func _play_pending_effects_after_action_line() -> void:
	if pending_effects_from_selected_target.is_empty():
		return
	var effects_to_play := pending_effects_from_selected_target.duplicate(true)
	pending_effects_from_selected_target.clear()
	await get_tree().create_timer(0.25).timeout
	for affected in effects_to_play:
		_queue_affected_popup(affected, true)
	_play_effect_popup_queue()

func _queue_affected_popup(affected: Dictionary, force_show := false) -> void:
	var affected_id := str(affected.get("id", ""))
	var popup_position := _find_effect_popup_position(affected)
	for change in affected.get("changes", []):
		var text := _get_change_popup_text(change)
		if str(change.get("name", "")) == "health" and float(change.get("value", 0)) < 0:
			play_game_sound("take_damage")
		if text == "":
			continue
		var effect_key := affected_id + ":" + str(change.get("name", ""))
		#if recently_shown_effect_keys.has(effect_key):
		if not force_show and recently_shown_effect_keys.has(effect_key):
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
			return "%s%s STR" % [sign, _format_effect_number(value)]
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

func _on_unit_right_clicked(_pos: Vector2, unit_id) -> void:
	var id := str(unit_id)

	if not known_units.has(id):
		return

	if hover_card_pinned and hover_card_pinned_unit_id == id:
		clear_all_hover_card_popups()
		return

	clear_all_hover_card_popups()

	hover_card_pinned = true
	hover_card_pinned_unit_id = id
	show_hover_unit_card_popup(id, _pos)

func _on_unit_hover_started(_pos: Vector2, unit_id) -> void:
	var id := str(unit_id)

	if not known_units.has(id):
		return

	hover_token += 1
	var my_token := hover_token

	hover_card_requested_unit_id = id
	hover_card_requested_pos = _pos
	hover_source_rect = Rect2(_pos - Vector2(127, 137), Vector2(254, 274))

	await get_tree().create_timer(hover_card_delay_seconds).timeout

	if my_token != hover_token:
		return

	if hover_card_requested_unit_id != id:
		return

	show_hover_unit_card_popup(id, _pos)

func _on_unit_hover_ended(unit_id) -> void:
	hover_card_requested_unit_id = ""
	hover_token += 1

	await get_tree().create_timer(hover_hide_delay_seconds).timeout

	if hover_card_pinned:
		return

	hide_hover_unit_card_popup()

func _is_mouse_over_hover_area() -> bool:
	var mouse_pos := get_global_mouse_position()

	if hover_source_rect.has_point(mouse_pos):
		return true

	if is_instance_valid(hover_card_popup):
		if hover_card_popup.get_global_rect().has_point(mouse_pos):
			return true

	return false

func show_action(payload):
	_play_sound_for_action(payload)
	combat_action_path.curve = Curve2D.new()
	var pos_1 = Vector2.ZERO
	if my_turn:
		pos_1 = Vector2(1528,1040)
	else:
		pos_1 = Vector2(1528,96)
	var pos_2 = Vector2.ZERO
	
	if payload.has("source_id") and payload.has("dest_id"):
		match str(payload.get("action", "")):
			"move":
				_animate_unit_move(str(payload["source_id"]), str(payload["dest_id"]))
			"use":
				_animate_unit_attack(str(payload["source_id"]), str(payload["dest_id"]))
	
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
	#if payload.has("affected"):
		#_play_affected_effects(payload["affected"])
	if payload.has("affected"):
		_play_affected_effects(payload["affected"], true)
	elif payload["action"] == "play" or payload["action"] == "use" or payload["action"] == "move":
		_play_pending_effects_after_action_line()

func _on_combat_action_timer_timeout():
	combat_action_path.curve.set_point_position(1,Vector2.ZERO)
	combat_action_path.curve.set_point_in(1,Vector2.ZERO)
	combat_action_line.clear_points()

func _on_card_get_info(data):
	if str(data["id"]) == card_view_id:
		card_view_id = ""
		side_tabs.current_tab = 0
		return
	get_info.emit(data)

func _on_side_tabs_tab_clicked(tab):
	if tab == log_tab_index:
		unread_log_count = 0
		_update_log_tab_title()

func _show_hover_unit_card_popup_after_delay(unit_id: String, hover_pos: Vector2) -> void:
	await get_tree().create_timer(hover_card_delay_seconds).timeout
	if hover_card_requested_unit_id != unit_id:
		return
	if not known_units.has(unit_id):
		return
	show_hover_unit_card_popup(unit_id, hover_pos)

func show_hover_unit_card_popup(unit_id: String, hover_pos: Vector2) -> void:
	if hover_card_popup_unit_id == unit_id and is_instance_valid(hover_card_popup):
		return

	hide_hover_unit_card_popup()

	if not known_units.has(unit_id):
		return

	var popup_card = CARD_SCENE.instantiate()
	popup_card.add_to_group("hover_card_popups")
	card_popup_layer.add_child(popup_card)

	hover_card_popup = popup_card
	hover_card_popup_unit_id = unit_id

	popup_card.define_scale(4)
	popup_card.add_details(known_units[unit_id], true)

	_make_control_tree_ignore_mouse(popup_card)

	# Let the card root catch right-clicks anywhere.
	popup_card.mouse_filter = Control.MOUSE_FILTER_STOP

	# Let rich text still catch/click links.
	_enable_hover_card_text_mouse(popup_card)

	popup_card.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				force_hide_hover_unit_card_popup()
	)

	popup_card.z_index = 1000
	popup_card.modulate.a = 0.0
	popup_card.global_position = _get_hover_card_popup_position(hover_pos)

	var tween := create_tween()
	tween.tween_property(popup_card, "modulate:a", 1.0, 0.12)

func _try_hide_hover_popup_after_delay(unit_id: String) -> void:
	await get_tree().create_timer(hover_hide_delay_seconds).timeout
	if hover_unit_mouse_over:
		return
	if hover_popup_mouse_over:
		return
	hide_hover_unit_card_popup(unit_id)

func hide_hover_unit_card_popup(unit_id := "") -> void:
	if hover_card_pinned:
		return

	if is_instance_valid(hover_card_popup):
		hover_card_popup.queue_free()

	hover_card_popup = null
	hover_card_popup_unit_id = ""

func force_hide_hover_unit_card_popup() -> void:
	if is_instance_valid(hover_card_popup):
		hover_card_popup.queue_free()

	hover_card_popup = null
	hover_card_popup_unit_id = ""
	hover_card_pinned = false
	hover_card_pinned_unit_id = ""

func _get_hover_card_popup_position(hover_pos: Vector2) -> Vector2:
	var popup_size := Vector2(326.4, 448)
	var popup_pos := hover_pos + Vector2(180, -280)
	var viewport_size := get_viewport_rect().size
	if popup_pos.x + popup_size.x > viewport_size.x:
		popup_pos.x = hover_pos.x - popup_size.x - 180
	if popup_pos.y < 0:
		popup_pos.y = 20
	if popup_pos.y + popup_size.y > viewport_size.y:
		popup_pos.y = viewport_size.y - popup_size.y - 20
	return popup_pos

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
	#_make_control_tree_ignore_mouse(popup_card)
	popup_card.mouse_filter = Control.MOUSE_FILTER_PASS
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

func _enable_hover_card_text_mouse(node: Node) -> void:
	if node is RichTextLabel:
		node.mouse_filter = Control.MOUSE_FILTER_STOP

	for child in node.get_children():
		_enable_hover_card_text_mouse(child)

func _get_tile_global_position_by_tile_id(tile_id: String) -> Vector2:
	for row in battlefield["grid"]:
		for col in row:
			if str(col.tile_id) == str(tile_id):
				return col.global_position
	return Vector2.ZERO

func _play_affected_effects(affected_list, force_show := false) -> void:
	if affected_list is String:
		affected_list = str_to_var(affected_list)
	if not affected_list is Array:
		return
	await get_tree().create_timer(0.25).timeout
	for affected in affected_list:
		_queue_affected_popup(affected, force_show)
	_play_effect_popup_queue()

func _find_effect_popup_position(affected: Dictionary) -> Vector2:
	if affected.has("popup_position"):
		return affected["popup_position"]
	var affected_id := str(affected.get("id", ""))
	if recent_tile_popup_positions.has(affected_id):
		return recent_tile_popup_positions[affected_id]
	if last_known_unit_positions.has(affected_id):
		return last_known_unit_positions[affected_id]["global_position"] + Vector2(80, 60)
	for row in battlefield["grid"]:
		for col in row:
			if affected_id == str(col.occupant_id) or affected_id == str(col.tile_id):
				return col.global_position + Vector2(80, 60)
	return Vector2(960, 540)

#func _find_effect_popup_position(affected: Dictionary) -> Vector2:
	#if affected.has("popup_position"):
		#return affected["popup_position"]
	#var affected_id := str(affected.get("id", ""))
	#for row in battlefield["grid"]:
		#for col in row:
			#if affected_id == str(col.occupant_id) or affected_id == str(col.tile_id):
				#return col.global_position + Vector2(80, 60)
	#if last_known_unit_positions.has(affected_id):
		#return last_known_unit_positions[affected_id]["global_position"] + Vector2(80, 60)
	#if affected.has("x") and affected.has("y"):
		#for row in battlefield["grid"]:
			#for col in row:
				#if int(col.get("x")) == int(affected["x"]) and int(col.get("y")) == int(affected["y"]):
					#return col.global_position + Vector2(80, 60)
	#return Vector2(960, 540)

func _queue_unit_stat_change_popups(unit: Dictionary, popup_position_override = null) -> void:
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
		var affected := {
			"id": unit_id,
			"x": unit.get("x", null),
			"y": unit.get("y", null),
			"changes": [fake_change]
		}
		if popup_position_override != null:
			affected["popup_position"] = popup_position_override
		_queue_affected_popup(affected)
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

func _connect_right_click_close_to_tree(node: Node) -> void:
	if node is Control:
		node.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
					force_hide_hover_unit_card_popup()
		)
	for child in node.get_children():
		_connect_right_click_close_to_tree(child)

func clear_all_hover_card_popups() -> void:
	for popup in get_tree().get_nodes_in_group("hover_card_popups"):
		if is_instance_valid(popup):
			popup.queue_free()
	hover_card_popup = null
	hover_card_popup_unit_id = ""
	hover_card_pinned = false
	hover_card_pinned_unit_id = ""

func _on_log_card_entry_hover_started(card_data: Dictionary) -> void:
	if hover_card_pinned:
		return
	log_card_hover_token += 1
	var my_token := log_card_hover_token
	await get_tree().create_timer(hover_card_delay_seconds).timeout
	if my_token != log_card_hover_token:
		return
	if hover_card_pinned:
		return
	show_log_card_popup(card_data, false)

func _on_log_card_entry_hover_ended() -> void:
	log_card_hover_token += 1
	await get_tree().create_timer(hover_hide_delay_seconds).timeout
	if hover_card_pinned:
		return
	hide_hover_unit_card_popup()

func _on_log_card_entry_right_clicked(card_data: Dictionary) -> void:
	var popup_id := str(card_data.get("id", card_data.get("name", "")))
	if hover_card_pinned and hover_card_pinned_unit_id == popup_id:
		clear_all_hover_card_popups()
		return
	clear_all_hover_card_popups()
	hover_card_pinned = true
	hover_card_pinned_unit_id = popup_id
	show_log_card_popup(card_data, true)

func show_log_card_popup(card_data: Dictionary, pinned := false) -> void:
	var popup_card = CARD_SCENE.instantiate()
	popup_card.add_to_group("hover_card_popups")
	card_popup_layer.add_child(popup_card)
	var popup_id := str(card_data.get("id", card_data.get("name", Time.get_ticks_msec())))
	hover_card_popup = popup_card
	hover_card_popup_unit_id = popup_id
	hover_card_pinned = pinned
	hover_card_pinned_unit_id = popup_id if pinned else ""
	popup_card.define_scale(4)
	popup_card.add_details(card_data, card_data.has("card"))
	popup_card.mouse_filter = Control.MOUSE_FILTER_STOP
	popup_card.z_index = 1000
	popup_card.global_position = log_visuals.global_position + Vector2(-360, 40)
	_connect_right_click_close_to_tree(popup_card)

func _get_tile_popup_position_from_payload(tile: Dictionary) -> Vector2:
	for row in battlefield["grid"]:
		for col in row:
			if str(col.tile_id) == str(tile.get("id", "")):
				return col.global_position + Vector2(80, 60)
			if tile.has("display_x") and tile.has("display_y"):
				if int(col.get("display_x")) == int(tile["display_x"]) and int(col.get("display_y")) == int(tile["display_y"]):
					return col.global_position + Vector2(80, 60)
	return Vector2(960, 540)

func _get_log_icon_key(payload: Dictionary) -> String:
	var statement := str(payload.get("statement", "")).to_lower()
	if statement.contains("draw"):
		return "draw"
	if statement.contains("died") or statement.contains("dies"):
		return "died"
	if statement.contains("attack"):
		return "attacks"
	if statement.contains("trap"):
		return "play_trap"
	if statement.contains("play"):
		for arg in payload.get("arguments", []):
			if arg is Dictionary:
				#print("*(**************)")
				#utils.j_print(arg)
				var subtype := str(arg.get("subtype", "")).to_lower()
				if subtype == "" and arg.has("card") and arg["card"] is Dictionary:
					subtype = str(arg["card"].get("subtype", "")).to_lower()
				if subtype == "trap":
					return "play_trap"
				if subtype == "unit" or subtype == "avatar":
					return "play_unit"
	return ""

func _add_log_event_icon(row: HBoxContainer, icon_key: String) -> void:
	if icon_key == "":
		return
	if not LOG_EVENT_ICONS.has(icon_key):
		return
	var icon := TextureRect.new()
	icon.texture = LOG_EVENT_ICONS[icon_key]
	icon.custom_minimum_size = Vector2(32, 32)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(icon)

func play_game_sound(sound_key: String, volume_db := 0.0) -> void:
	if sound_key == "":
		return
	if not Sounds.sounds.has(sound_key):
		return
	Sounds.play_sound(sound_key, 1, volume_db)

func _play_sound_for_action(payload: Dictionary) -> void:
	match str(payload.get("action", "")):
		"move":
			play_game_sound("move_unit")
		"use":
			play_game_sound("attack")
		"play":
			play_game_sound(_get_play_sound_key(payload))

func _get_play_sound_key(payload: Dictionary) -> String:
	var subtype := ""
	for key in ["card", "unit", "source"]:
		if payload.has(key) and payload[key] is Dictionary:
			subtype = str(payload[key].get("subtype", "")).to_lower()
			if subtype != "":
				break
	match subtype:
		"potion":
			return "play_potion"
		"trap":
			return "play_trap"
		_:
			return "play_unit"


#ANIMATIONS

func _get_grid_space_by_id(id: String):
	for row in battlefield["grid"]:
		for col in row:
			if str(col.tile_id) == id or str(col.occupant_id) == id:
				return col
	return null

func _animate_unit_move(source_id: String, dest_id: String) -> void:
	var source_space = _get_grid_space_by_id(source_id)
	var dest_space = _get_grid_space_by_id(dest_id)
	if source_space == null or dest_space == null:
		return
	var source_visual = source_space.unit_content
	var dest_visual = dest_space.unit_content
	if source_visual == null or dest_visual == null:
		return
	var ghost = source_visual.duplicate()
	card_popup_layer.add_child(ghost)
	ghost.global_position = source_visual.global_position
	ghost.scale = source_visual.scale
	ghost.z_index = 950
	_make_control_tree_ignore_mouse(ghost)
	source_visual.modulate.a = 0.0
	dest_visual.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(ghost, "global_position", dest_visual.global_position, 0.25)
	tween.finished.connect(func():
		if is_instance_valid(dest_visual):
			dest_visual.modulate.a = 1.0
		if is_instance_valid(source_visual):
			source_visual.modulate.a = 1.0
		if is_instance_valid(ghost):
			ghost.queue_free()
	)

func _animate_unit_attack(source_id: String, dest_id: String) -> void:
	var source_space = _get_grid_space_by_id(source_id)
	var dest_space = _get_grid_space_by_id(dest_id)
	if source_space == null or dest_space == null:
		return
	var source_visual = source_space.unit_content
	if source_visual == null:
		return
	var ghost = source_visual.duplicate()
	card_popup_layer.add_child(ghost)
	ghost.global_position = source_visual.global_position
	ghost.scale = source_visual.scale
	ghost.z_index = 950
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_make_control_tree_ignore_mouse(ghost)
	source_visual.modulate.a = 0.0
	var start_pos = source_visual.global_position
	var target_pos = dest_space.unit_content.global_position
	var hit_pos = start_pos.lerp(target_pos, 0.82)
	var tween := create_tween()
	tween.tween_property(ghost, "global_position", hit_pos, 0.16)
	if is_instance_valid(source_visual):
		tween.tween_property(ghost, "global_position", start_pos, 0.14)
	tween.finished.connect(func():
		if is_instance_valid(source_visual):
			source_visual.modulate.a = 1.0
		if is_instance_valid(ghost):
			ghost.queue_free()
	)

func _animate_unit_played(tile_id: String) -> void:
	var grid_space = _get_grid_space_by_id(tile_id)
	if grid_space == null:
		return
	var visual = grid_space.unit_content
	if visual == null:
		return
	var original_scale = visual.scale
	visual.pivot_offset = visual.size / 2.0
	visual.scale = original_scale * 1.45
	var tween := create_tween()
	tween.tween_property(visual, "scale", original_scale * 0.92, 0.14)
	tween.tween_property(visual, "scale", original_scale, 0.08)
