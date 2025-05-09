extends Control

var height = 0
var width = 0
var shape = []
var shape_color = "FFFFFF"
var start = Vector2.ZERO
var minSizeOfSquares = 0.0
var screensize = Vector2(400,400)
var grid_square_size = 10

func reset_active_component():
	height = 0
	width = 0
	shape = []
	shape_color = "FFFFFF"
	start = Vector2.ZERO
	minSizeOfSquares = 0.0
	queue_redraw()

func create_active_component(component_payload):
	#print(component_payload)
	height = int(component_payload["shape"].size())
	width = int(component_payload["shape"].size())
	shape = component_payload["shape"]
	shape_color = component_payload["color"]["background_color"]
	start = Vector2(int(component_payload["x"]),int(component_payload["y"]))
	#print(start)
	findSizeOfSquares()
	queue_redraw()

func findSizeOfSquares():
	if height < width:
		minSizeOfSquares = screensize.x/width
	elif width <= height:
		minSizeOfSquares = screensize.y/height
	minSizeOfSquares = grid_square_size

func _draw():
	for child in $icons.get_children():
		child.queue_free()
	if (height == 0 and width == 0):
		return
	else:
		@warning_ignore("unused_variable")
		var i = 0
		for x in width:
			if height % 2 == 0:
				i+=1
			for y in height:
				var pos = Vector2(x*minSizeOfSquares,y*minSizeOfSquares)
				var rect = Rect2(pos,Vector2(minSizeOfSquares,minSizeOfSquares))
				var col = Color(shape_color,.75)
				if shape[y][x] == 0 or shape[y][x] == 2:
					col = Color(1,1,1,0)
					#col = Color.BLUE_VIOLET
				draw_rect(rect,col)
				i+=1
