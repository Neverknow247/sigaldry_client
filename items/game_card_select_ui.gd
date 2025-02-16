extends ColorRect

signal mouse_released
signal picked_up_changed(picked)
signal focus(_focus)

@onready var timer = $Timer
@onready var path_2d = $Path2D
@onready var line_2d = $Line2D

var click_hover = false
var card_middle = Vector2(128,176)

var picked_up : bool = false:
	set(b):
		if not b:
			position = Vector2.ZERO
			path_2d.curve.set_point_position(1,Vector2.ZERO)
			path_2d.curve.set_point_in(1,Vector2.ZERO)
			line_2d.clear_points()
		picked_up = b
		on_focus(b)
		picked_up_changed.emit(b)

func _ready():
	path_2d.curve = Curve2D.new()
	path_2d.curve.add_point(global_position)
	path_2d.curve.add_point(global_position)
	path_2d.curve.bake_interval = 50

func _process(delta):
	if picked_up:
		path_2d.curve.set_point_position(1,get_global_mouse_position()-card_middle)
		path_2d.curve.set_point_in(1,Vector2(get_local_mouse_position().x,(get_local_mouse_position().y-card_middle.y)/2)*-1)
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

signal mouse_focus(_pos,_focus,card_id)

func _on_card_select_mouse_entered():
	mouse_focus.emit(global_position,true)
	#if not Input.is_action_pressed("M1") && click_hover == false:
		#on_focus(true)

func _on_card_select_mouse_exited():
	mouse_focus.emit(global_position,false)
	#if not Input.is_action_pressed("M1") && click_hover == false:
		#on_focus(false)

func _on_card_select_pressed():
	if not picked_up:
		timer.start()

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
