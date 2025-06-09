extends TextureRect

const GRID_SPACE = preload("res://game_scenes/grid_space.tscn")

@onready var grid_container = $GridContainer

var grid = []
var display_grid = []

var height = 270
var width = 270

var cols = 0
var rows = 0

var disposition_override = false
var disposition_color = "FFFFFF"
var disposition_on_color = "FF0000"
var disposition_off_color = "FFFFFF"

func _draw():
	for x in range(cols):
		for y in range(rows):
			draw_rect(Rect2(Vector2(x*width,y*height),Vector2(width,height)),disposition_color,false,2)

func change_disposition(_disposition_override):
	disposition_color = disposition_on_color if _disposition_override else disposition_off_color
	queue_redraw()

func create_grid(_cols,_rows):
	for child in grid_container.get_children():
		grid_container.remove_child(child)
		child.queue_free()
	grid = []
	display_grid = []
	cols = _cols
	rows = _rows
	queue_redraw()
	for x in range(_rows):
		grid.append([])
		display_grid.append([])
		for y in range(_cols):
			var new_grid_space = GRID_SPACE.instantiate()
			grid[x].append(new_grid_space)
			grid_container.add_child(new_grid_space)
	#print("grid: ",grid)
	return

func set_grid_space(info):
	#print(info)
	#var grid_space = grid[info["game_y"]][info["game_x"]]
	var grid_space = grid[info["display_y"]][info["display_x"]]
	grid_space["control"].visible = info["occupied"]
	grid_space["trap"].visible = info["trapped"]
	grid_space["tile_id"] = info["id"]
	grid_space["tile_type"] = info["type"]
	grid_space["card"]["type"] = "game_type"
	if info["occupied"]:
		grid_space["occupied"] = true
		grid_space["occupant_id"] = info["occupant"]["id"]
		grid_space["occupant_type"] = info["occupant"]["type"]
		grid_space["card"]["card_name"].text = info["occupant"]["name"]
		
		grid_space["card"]["card_id"] = info["occupant"]["id"]
		grid_space["card"]["source_type"] = info["occupant"]["subtype"]
		grid_space["card"]["card_type"].text = info["occupant"]["subtype"].capitalize()
		if info["occupant"]["subtype"] == "avatar":
			grid_space.set_avatar(true)
		else:
			grid_space.set_avatar(false)
		if info["occupant"]["exhausted"]:
			grid_space["control"].rotation_degrees = 35
		else:
			grid_space["control"].rotation_degrees = 0
	else:
		grid_space["occupied"] = false
		grid_space["occupant_id"] = ""
		grid_space["occupant_type"] = ""

func update_grid_space(info):
	#print("updating")
	#print(info)
	#print(info["tile"]["id"])
	var grid_space
	for x in grid:
		for y in x:
			#print("matching?: ", info["tile"]["id"]," - ", y.tile_id)
			if info["tile"]["id"] == y.tile_id:
				grid_space = y
			#print(y.occupant_id)
	#var grid_space = grid[info["tile"]["y"]][info["tile"]["x"]]
	#var grid_space = grid[info["tile"]["display_y"]][info["tile"]["display_x"]]
	grid_space["control"].visible = info["tile"]["occupied"]
	grid_space["trap"].visible = info["tile"]["trapped"]
	if info["tile"]["occupied"]:
		#print("******************")
		#print(info["tile"])
		#print(info["tile"]["occupant"])
		#print(info["tile"]["occupant"]["exhausted"])
		grid_space["occupied"] = true
		grid_space["occupant_id"] = info["tile"]["occupant"]["id"]
		grid_space["occupant_type"] = info["tile"]["occupant"]["type"]
		grid_space["card"]["card_name"].text = info["tile"]["occupant"]["name"]
		grid_space["card"]["card_id"] = info["tile"]["occupant"]["id"]
		grid_space["card"]["source_type"] = info["tile"]["occupant"]["subtype"]
		grid_space["card"]["card_type"].text = info["tile"]["occupant"]["subtype"].capitalize()
		if info["tile"]["occupant"]["subtype"] == "avatar":
			grid_space.set_avatar(true)
		else:
			grid_space.set_avatar(false)
		if info["tile"]["occupant"]["exhausted"]:
			grid_space["control"].rotation_degrees = 35
		else:
			grid_space["control"].rotation_degrees = 0
		var abilities = info["tile"]["occupant"]["abilities"]
		for ability in abilities:
			if abilities[ability]["name"] == "health":
				var card_hp = abilities[ability]["value"]
				grid_space["card"]["card_health"].text = str(int(card_hp)) if card_hp > 0 else ""
			elif abilities[ability]["name"] == "attack":
				grid_space["card"]["card_attack"].text = str(int(abilities[ability]["value"]))
	elif info["tile"]["trapped"]:
		print("*****")
		#print(info["tile"])
		#print("*****")
		#print("Trapped Tile")
	else:
		#print(info["tile"])
		grid_space["occupied"] = false
		grid_space["occupant_id"] = ""
		grid_space["occupant_type"] = ""

func update_unit(info):
	#print(info["unit"]["name"])
	#print(info["unit"]["x"],":",info["unit"]["y"])
	#print("dead: ",info["unit"]["dead"])
	if !info["unit"]["tile_id"]:
		#print("returning now")
		return
	
	var grid_space
	for x in grid:
		for y in x:
			#print("matching?: ", info["unit"]["id"]," - ", y.occupant_id)
			if info["unit"]["id"] == y.occupant_id:
				grid_space = y
	
	#var grid_space = grid[info["unit"]["y"]][info["unit"]["x"]]
	#var grid_space = grid[info["unit"]["display_y"]][info["unit"]["display_x"]]
	grid_space["control"].visible = !info["unit"]["dead"]
	if !info["unit"]["dead"]:
		grid_space["card"]["card_name"].text = info["unit"]["name"]
		grid_space["card"]["card_id"] = info["unit"]["id"]
		grid_space["card"]["card_type"].text = info["unit"]["subtype"].capitalize()
		grid_space["card"]["type"] = "game_type"
		print("exhausted: ",info["unit"]["exhausted"])
		if info["unit"]["exhausted"]:
			grid_space["control"].rotation_degrees = 35
		else:
			grid_space["control"].rotation_degrees = 0
		var abilities = info["unit"]["abilities"]
		for ability in abilities:
			if abilities[ability]["name"] == "health":
				var card_hp = abilities[ability]["value"]
				grid_space["card"]["card_health"].text = str(int(card_hp)) if card_hp > 0 else ""
			elif abilities[ability]["name"] == "attack":
				grid_space["card"]["card_attack"].text = str(int(abilities[ability]["value"]))
	else:
		grid_space["card"]["card_id"] = 0
		grid_space["card"]["type"] = ""
