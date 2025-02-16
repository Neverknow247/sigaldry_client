extends TextureRect

@onready var _0_0 = $"GridContainer/0,0"
@onready var _1_0 = $"GridContainer/1,0"
@onready var _2_0 = $"GridContainer/2,0"
@onready var _3_0 = $"GridContainer/3,0"
@onready var _4_0 = $"GridContainer/4,0"
@onready var _0_1 = $"GridContainer/0,1"
@onready var _1_1 = $"GridContainer/1,1"
@onready var _2_1 = $"GridContainer/2,1"
@onready var _3_1 = $"GridContainer/3,1"
@onready var _4_1 = $"GridContainer/4,1"
@onready var _0_2 = $"GridContainer/0,2"
@onready var _1_2 = $"GridContainer/1,2"
@onready var _2_2 = $"GridContainer/2,2"
@onready var _3_2 = $"GridContainer/3,2"
@onready var _4_2 = $"GridContainer/4,2"
@onready var _0_3 = $"GridContainer/0,3"
@onready var _1_3 = $"GridContainer/1,3"
@onready var _2_3 = $"GridContainer/2,3"
@onready var _3_3 = $"GridContainer/3,3"
@onready var _4_3 = $"GridContainer/4,3"

@onready var grid = [
	[_0_0,_1_0,_2_0,_3_0,_4_0],
	[_0_1,_1_1,_2_1,_3_1,_4_1],
	[_0_2,_1_2,_2_2,_3_2,_4_2],
	[_0_3,_1_3,_2_3,_3_3,_4_3],
]


var height = 270
var width = 270

var col = 5
var row = 4

func _draw():
	for x in range(col):
		for y in range(row):
			draw_rect(Rect2(Vector2(x*width,y*height),Vector2(width,height)),"#FFFFFF",false,2)

func set_grid_space(info):
	var grid_space = grid[info["game_y"]][info["game_x"]]
	grid_space["control"].visible = info["occupied"]
	grid_space["tile_id"] = info["id"]
	if info["occupied"]:
		grid_space["card"]["card_name"].text = info["occupant"]["name"]
		grid_space["card"]["card_type"].text = info["occupant"]["subtype"].capitalize()
		if info["occupant"]["exhausted"]:
			grid_space["control"].rotation_degrees = 35
		else:
			grid_space["control"].rotation_degrees = 0

func update_grid_space(info):
	#print("updating")
	var grid_space = grid[info["tile"]["y"]][info["tile"]["x"]]
	grid_space["control"].visible = info["tile"]["occupied"]
	if info["tile"]["occupied"]:
		#print(info["tile"]["occupant"]["exhausted"])
		grid_space["card"]["card_name"].text = info["tile"]["occupant"]["name"]
		grid_space["card"]["card_type"].text = info["tile"]["occupant"]["subtype"].capitalize()
		if info["tile"]["occupant"]["exhausted"]:
			grid_space["control"].rotation_degrees = 35
		else:
			grid_space["control"].rotation_degrees = 0

func update_unit(info):
	print(info["unit"]["name"])
	print(info["unit"]["x"],":",info["unit"]["y"])
	print("dead: ",info["unit"]["dead"])
	if !info["unit"]["tile_id"]:
		print("returning now")
		return
	var grid_space = grid[info["unit"]["y"]][info["unit"]["x"]]
	grid_space["control"].visible = !info["unit"]["dead"]
	if !info["unit"]["dead"]:
		grid_space["card"]["card_name"].text = info["unit"]["name"]
		grid_space["card"]["card_type"].text = info["unit"]["subtype"].capitalize()
		print("exhausted: ",info["unit"]["exhausted"])
		if info["unit"]["exhausted"]:
			grid_space["control"].rotation_degrees = 35
		else:
			grid_space["control"].rotation_degrees = 0
