extends Control

var stats = Stats

var height = 0
var width = 0
var tiles = []
var minSizeOfSquares = 0.0
var screensize = Vector2(100,100)

func create_template_shapes(template_payload):
	#print(template_payload)
	height = int(template_payload["max_height"])
	width = int(template_payload["max_width"])
	tiles = template_payload["tiles"]
	#component_color = template_payload["color_profile"]["background_color"]
	#start = Vector2(int(components_payload["start"]["x"]),int(components_payload["start"]["y"]))
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
				var col = stats.color_one
				if (i%2):
					col = stats.color_two
				if tiles[y][x] == 0:
					col = Color(1,1,1,0)
				elif tiles[y][x] == 5:
					col = Color.AQUAMARINE
				draw_rect(rect,col)
				draw_rect(rect,Color("#2b2d31"),false,3)
				#draw_rect(rect,Color(0, 0, 0, 0),false,3)
				#draw_rect(rect,Color("#3e4144"),false,3)
				#draw_rect(rect,Color.DIM_GRAY,false,3)
				i+=1
