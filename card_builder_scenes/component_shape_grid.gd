extends Control

const StoneTileScript = preload("res://tools/stone_tile.gd")

var height = 0
var width = 0
var tiles = []
var component_color = "EEEEEE"
var minSizeOfSquares = 0.0
var screensize = Vector2(100,100)

var stone_tile := StoneTileScript.new()

func create_component_shapes(components_payload):
	height = int(components_payload["shape"].size())
	width = int(components_payload["shape"].size())
	tiles = components_payload["shape"]
	component_color = components_payload["color_profile"]["background_color"]
	#start = Vector2(int(components_payload["start"]["x"]),int(components_payload["start"]["y"]))
	findSizeOfSquares()
	queue_redraw()

func findSizeOfSquares():
	if height < width:
		minSizeOfSquares = screensize.x/width
	elif width <= height:
		minSizeOfSquares = screensize.y/height

func _draw():
	#for child in $icons.get_children():
		#child.queue_free()
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
				if tiles[y][x] == 0:
					col = Color(1,1,1,0)
				elif tiles[y][x] == 5:
					col = Color.AQUAMARINE
				stone_tile.draw(self,rect,col)
				i+=1
