extends Control

var stats = Stats

var height = 0
var width = 0
var tiles = []
var component_color = "EEEEEE"
var minSizeOfSquares = 0.0
var screensize = Vector2(80,80)

var shape_type = ""

func create_template_shapes(template_payload):
	shape_type = "template"
	height = int(template_payload["max_height"])
	width = int(template_payload["max_width"])
	tiles = template_payload["tiles"]
	findSizeOfSquares()
	queue_redraw()

func create_component_shapes(components_payload):
	shape_type = "component"
	height = int(components_payload["shape"].size())
	width = int(components_payload["shape"].size())
	tiles = components_payload["shape"]
	component_color = stats["COLOR_KEY"][components_payload["color_profile"]["key"]]
	findSizeOfSquares()
	queue_redraw()

func findSizeOfSquares():
	if height < width:
		minSizeOfSquares = screensize.x/width
	elif width <= height:
		minSizeOfSquares = screensize.y/height

func _draw():
	if height == 0 and width == 0:
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
				var col = Color(component_color)
				if shape_type == "template":
					col = stats.color_one
					if (i%2):
						col = stats.color_two
					if tiles[y][x] == 0:
						col = Color(1,1,1,0)
				elif shape_type == "component":
					col = Color(component_color)
					if tiles[y][x] == 0:
						col = Color(1,1,1,0)
					elif tiles[y][x] == 5:
						col = Color.AQUAMARINE
				draw_rect(rect,col)
				draw_rect(rect,Color("#383838"),false,3)
				i+=1
