extends Control

var scene_name = "game"

const card_preview = preload("res://items/card_preview.tscn")

signal end_turn
signal concede

@onready var battlefield = $battlefield

@onready var enemy_energy = $side_panel/ColorRect/enemy_panel/energy/enemy_energy
@onready var enemy_hand_size = $side_panel/ColorRect/enemy_panel/cards_in_hand/enemy_hand_size
@onready var enemy_deck_size = $side_panel/ColorRect/enemy_panel/cards_in_deck/enemy_deck_size
@onready var enemy_victory_points = $side_panel/ColorRect/enemy_panel/victory_points/enemy_victory_points

@onready var hand = $side_panel/ColorRect/hand_preview/hand

@onready var my_energy = $side_panel/ColorRect/player_panel/info/energy/my_energy
@onready var my_hand_size = $side_panel/ColorRect/player_panel/info/cards_in_hand/my_hand_size
@onready var my_deck_size = $side_panel/ColorRect/player_panel/info/cards_in_deck/my_deck_size
@onready var my_victory_points = $side_panel/ColorRect/player_panel/info/victory_points/my_victory_points

@onready var end_turn_button = $side_panel/ColorRect/player_panel/buttons/end_turn_button

@onready var timer = $card_controller/Timer
@onready var path_2d = $card_controller/Path2D
@onready var line_2d = $card_controller/Line2D

var click_hover = false
var card_middle = Vector2(128,176)

signal mouse_released
#signal picked_up_changed(picked)
signal focus(_focus)

func join_game(payload):
	#print("join game: ",payload)
	for tile in payload["board"]["tiles"]:
		print(tile)
		battlefield.set_grid_space(tile)
	pass

func update_unit(payload):
	#print("update unit: ",payload)
	#print("update unit: ",payload["unit"]["x"])
	battlefield.update_unit(payload)
	pass
	

func update_turn(payload):
	#print("update turn: ",payload)
	if payload["active_avatar_id"]:
		if payload["active_avatar_id"] == payload["my_avatar_id"]:
			end_turn_button.text = "End Turn"
			end_turn_button.disabled = false
		else:
			end_turn_button.text = "Opponent's Turn"
			end_turn_button.disabled = true

func add_combat_log(payload):
	#print("add combat log: ",payload)
	return
	print("argument size: ",payload["arguments"].size())
	for item in payload["arguments"][0]:
		print(item)

func update_energy(payload):
	my_energy.text = str(payload["energy"])
	enemy_energy.text = str(payload["opponent_energy"])

func update_players(payload):
	#print(payload)
	#for key in payload:
		#print(key)
	my_deck_size.text = str(payload["my_deck_size"])
	enemy_deck_size.text = str(payload["opponent_deck_size"])
	my_hand_size.text = str(payload["my_hand_size"])
	enemy_hand_size.text = str(payload["opponent_hand_size"])
	my_energy.text = str(payload["my_energy"])
	enemy_energy.text = str(payload["opponent_energy"])
	my_victory_points.text = str(payload["my_victory_points"])
	enemy_victory_points.text = str(payload["opponent_victory_points"])
	var hand_width = 2
	var card_number = 0
	var row_node
	for child in hand.get_children():
		hand.remove_child(child)
		child.queue_free()
	for unit in payload["my_hand"]:
		if card_number == 0:
			row_node = HBoxContainer.new()
			hand.add_child(row_node)
			row_node.alignment = BoxContainer.ALIGNMENT_CENTER
			row_node.add_theme_constant_override("separation",10)
		var new_card = card_preview.instantiate()
		row_node.add_child(new_card)
		new_card["card_name"].text = unit["name"]
		new_card["card_id"] = unit["id"]
		new_card["card_type"].text = unit["subtype"].capitalize()
		new_card["type"] = "game_type"
		new_card["card_select"].connect("pressed",_on_card_select_pressed)
		new_card.connect("mouse_focus",_on_card_select_mouse_focus)
		var card_effect_text = ""
		var discount = 0
		for ability in unit["abilities"]:
			#print(ability)
			if unit["abilities"][ability]["name"] == "health":
				new_card["card_health"].text = str(unit["abilities"][ability]["value"])
			elif unit["abilities"][ability]["name"] == "attack":
				new_card["card_attack"].text = str(unit["abilities"][ability]["value"])
			elif unit["abilities"][ability]["name"] == "actions":
				pass
			elif unit["abilities"][ability]["name"] == "efficiant":
				discount = unit["abilities"][ability]["value"]
			elif unit["abilities"][ability]["value"] > 0:
				card_effect_text += unit["abilities"][ability]["name"].capitalize() + "-" + str(unit["abilities"][ability]["value"]) + " "
		new_card["card_effects"].text = card_effect_text
		new_card["card_price"].text = str(unit["cost"]-discount)
		card_number+=1
		if card_number == hand_width:
			card_number = 0

func update_tile(payload):
	#print("update tile: ",payload)
	battlefield.update_grid_space(payload)
	#for tile in payload["tile"]:
		#print(tile)
		#battlefield.update_grid_space(tile)
	#pass

func update_victory_points(payload):
	my_victory_points.text = str(payload["points"])
	enemy_victory_points.text = str(payload["opponent_points"])
	#print(payload)

func _on_end_turn_button_pressed():
	end_turn.emit()

func _on_concede_button_pressed():
	concede.emit()

signal test_play(play_info)
func _on_button_pressed():
	test_play.emit({"source_id":$LineEdit.text,"source_type":"card","disposition_override":"false","dest_id":selected_tile_id,"dest_type":"tile"})

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

func _ready():
	path_2d.curve = Curve2D.new()
	path_2d.curve.add_point(global_position)
	#path_2d.curve.add_point(global_position)
	path_2d.curve.bake_interval = 50

func _process(delta):
	if picked_up:
		path_2d.curve.set_point_position(1,get_local_mouse_position()-card_middle)
		path_2d.curve.set_point_in(1,(Vector2(get_local_mouse_position().x-1000,get_local_mouse_position().y)/2)*-1)
		#path_2d.curve.set_point_in(1,Vector2(get_local_mouse_position().x,(get_local_mouse_position().y-card_middle.y)/2)*-1)
		_draw_line()
	if Input.is_action_just_released("M1"):
		mouse_released.emit()

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
func _on_card_select_mouse_focus(_pos,_focus,_id):
	if not Input.is_action_pressed("M1") && click_hover == false:
		on_focus(_focus)
		path_2d.curve = Curve2D.new()
		path_2d.curve.add_point(_pos)
		path_2d.curve.add_point(_pos)
		print("card id: ",_id)
		focused_card = _id

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
	test_play.emit({"source_id":str(focused_card),"source_type":"card","disposition_override":"false"})

func _on_mouse_released():
	if not timer.is_stopped():
		timer.stop()
		picked_up = true
		click_hover = true
		await mouse_released
		picked_up = false
		click_hover = false

func _on_timer_timeout():
	if not picked_up:
		picked_up = true
		await mouse_released
		picked_up = false


func _on_focus(_focus):
	if _focus == true:
		#print(card_id)
		print("FOCUSING")
		#focused_card.emit()
		#select_card.emit(card_id)
	else:
		pass
