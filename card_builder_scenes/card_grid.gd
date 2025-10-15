extends Control

var stats = Stats

const start_icon = preload("res://items/start_icon.tscn")
const plus_one_icon = preload("res://items/plus_one_icon.tscn")
const plus_two_icon = preload("res://items/plus_two_icon.tscn")
const plus_unknown_icon = preload("res://items/plus_unknown_icon.tscn")
const times_two_icon = preload("res://items/times_two_icon.tscn")

var height = 0
var width = 0
var tiles = []
var start = Vector2.ZERO
var bonuses = []
var minSizeOfSquares = 0.0
var screensize = Vector2(400,400)
var grid_square_size = 100

#Other Colors I Like
#@export var color_one = Color("#333f58")
#@export var color_two = Color("#292831")
#Color("#c0d4c9") and Color("#6fb6ae")
#Color("#fbbbad") and Color("#ee8695")

var active_component_height = 0
var active_component_width = 0
var shape = []
var active_component_start = Vector2.ZERO
signal active_component_changed(val)
var active_component = false :
	set(value):
		active_component = value
		active_component_changed.emit(value)
		if value == true and hide_mouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
var active_component_color = "Clear"

var current_components = false
var component_shapes = []

func _ready():
	$active_component.grid_square_size = grid_square_size

func reset_card_grid():
	height = 0
	width = 0
	tiles = []
	start = Vector2.ZERO
	bonuses = []
	minSizeOfSquares = 0.0

func create_card_grid(grid_payload,components):
	if !grid_payload:
		return
	active_component = false
	if components:
		current_components = true
		component_shapes = components
	else:
		current_components = false
		component_shapes = []
	height = int(grid_payload["max_height"])
	width = int(grid_payload["max_width"])
	tiles = grid_payload["tiles"]
	start = Vector2(int(grid_payload["start"]["x"]),int(grid_payload["start"]["y"]))
	#print(start)
	bonuses = grid_payload["bonuses"]
	#print(bonuses)
	findSizeOfSquares()
	queue_redraw()

func findSizeOfSquares():
	if height < width:
		minSizeOfSquares = screensize.x/width
	elif width <= height:
		minSizeOfSquares = screensize.y/height
	minSizeOfSquares = grid_square_size

var grid_mouse_pos = Vector2.ZERO

func _draw():
	for child in $icons.get_children():
		child.queue_free()
		pass
	if height == 0 and width == 0:
		return
	else:
		var i = 0
		for x in width:
			if height % 2 == 0:
				i+=1
			for y in height:
				var pos = Vector2(x*minSizeOfSquares,y*minSizeOfSquares)
				var rect = Rect2(pos,Vector2(minSizeOfSquares,minSizeOfSquares))
				var col = stats.color_one
				@warning_ignore("unused_variable")
				var second_col = Color.BLACK
				if (i%2):
					col = stats.color_two
				if tiles[y][x] == 0:
					col = Color(1,1,1,0)
					second_col = Color(1,1,1,1)
				var mouse_pos = get_local_mouse_position().snapped(Vector2(grid_square_size,grid_square_size))
				if (mouse_pos.x >= pos.x and mouse_pos.x < pos.x+grid_square_size) and (mouse_pos.y >= pos.y and mouse_pos.y < pos.y+grid_square_size):
					#col = Color.TEAL
					grid_mouse_pos = pos/grid_square_size
				if current_components:
					for _component in component_shapes:
						#if _component == component_shapes[component_shapes.size()-1]:
							#print("last")
						if (x >= _component["x"] and x < _component["x"]+_component["shape"].size()) and (y >= _component["y"] and y < _component["y"]+_component["shape"].size()):
							#print(y-_component["y"])
							if _component["shape"][y-_component["y"]][x-_component["x"]] == 1 || _component["shape"][y-_component["y"]][x-_component["x"]] == 5:
								col = Color.DIM_GRAY
								second_col = Color(1,1,1,0)
								if _component == component_shapes[component_shapes.size()-1]:
									col = Color(_component["color_profile"]["background_color"])
									second_col = Color(1,1,1,0)
							if _component["shape"][y-_component["y"]][x-_component["x"]] == 5:
								col = Color.AQUAMARINE
				
				#if active_component:
					##print(active_component_start)
					#if (x >= active_component_start.x and x < active_component_start.x+active_component_width) and (y >= active_component_start.y and y < active_component_start.y+active_component_height):
						#if shape[y-active_component_start.y][x-active_component_start.x] == 1:
							#col = Color(active_component_color,.5)
				draw_rect(rect,col)
				#draw_rect(rect,second_col,false,4)
				if x == start.x and y == start.y:
					var start_point = start_icon.instantiate()
					start_point.global_position = pos + Vector2(minSizeOfSquares,minSizeOfSquares)/2
					$icons.add_child(start_point)
				for bonus in bonuses:
					if x == bonus["x"] and y == bonus["y"]:
						if bonus["type"] == "addition":
							var plus_icon
							if bonus["description"] == "+1":
								plus_icon = plus_one_icon.instantiate()
							elif bonus["description"] == "+2":
								plus_icon = plus_two_icon.instantiate()
							else:
								plus_icon = plus_unknown_icon.instantiate()
							plus_icon.global_position = pos + Vector2(minSizeOfSquares,minSizeOfSquares)/2
							$icons.add_child(plus_icon)
						elif bonus["type"] == "multiplication":
							var times_two = times_two_icon.instantiate()
							times_two.global_position = pos + Vector2(minSizeOfSquares,minSizeOfSquares)/2
							$icons.add_child(times_two)
				i+=1

@warning_ignore("unused_parameter")
func _process(delta):
	queue_redraw()
	@warning_ignore("integer_division")
	$active_component.position = ((get_local_mouse_position() - Vector2(minSizeOfSquares,minSizeOfSquares)/2) - ((Vector2.ONE*grid_square_size)*(shape.size()/2)) + (Vector2.ONE*grid_square_size/2)).snapped(Vector2(grid_square_size,grid_square_size))

signal check_placement_pos(default_pos,possible_pos)
signal piece_rotate(_direction)
signal component_removed

func _input(event):
	if event.is_pressed() and event is InputEventMouse:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if active_component:
				@warning_ignore("integer_division")
				check_placement_pos.emit(active_component_start,grid_mouse_pos-(Vector2.ONE*(shape.size()/2)))
				@warning_ignore("integer_division")
				active_component_start = grid_mouse_pos-(Vector2.ONE*(shape.size()/2))
				#print(grid_mouse_pos)
				#print("its a mouse click")
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if active_component:
				piece_rotate.emit("clockwise")
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if active_component:
				piece_rotate.emit("counterclockwise")
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			if active_component:
				component_removed.emit()
				#piece_rotate.emit()
	else:
		pass

func create_component_shapes(component_payload):
	active_component = true
	active_component_color = component_payload["color_profile"]["background_color"]
	active_component_height = int(component_payload["shape"].size())
	active_component_width = int(component_payload["shape"].size())
	shape = component_payload["shape"]
	active_component_start = Vector2(int(component_payload["x"]),int(component_payload["y"]))
	queue_redraw()

var hide_mouse = false
func _on_mouse_entered():
	if active_component:
		hide_mouse = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_mouse_exited():
	hide_mouse = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
