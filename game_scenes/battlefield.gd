extends TextureRect

#const GRID_SPACE = preload("res://game_scenes/grid_space.tscn")
const GRID_SPACE = preload("res://game_scenes/unit.tscn")
const GAME_EFFECT = preload("res://game_scenes/game_effect_queue.tscn")

@onready var grid_container = $GridContainer

var grid = []
var display_grid = []


#var height = 270
var width = 276
var height = 254
#var width = 254
#var width = 300

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
			#var overlay := new_grid_space.get_node("unit_content/grey_scale_overlay") as ColorRect
			#var shared_mat := overlay.material
			#overlay.material = shared_mat.duplicate()
			#overlay.material = overlay.material.duplicate()
			grid[x].append(new_grid_space)
			grid_container.add_child(new_grid_space)
			#new_grid_space.grey_scale_overlay.material = new_grid_space.grey_scale_overlay.material.duplicate(true)
			#var test = new_grid_space.grey_scale_overlay as ColorRect
	#print("grid: ",grid)
	return

func set_grid_space(info):
	#print(info)
	#var grid_space = grid[info["game_y"]][info["game_x"]]
	var grid_space = grid[info["display_y"]][info["display_x"]]
	
	grid_space.set_up_unit(info)
	
	#grid_space.set_up_unit(info)
	
	
	#grid_space["control"].visible = info["occupied"]
	#grid_space["trap"].visible = info["trapped"]
	#grid_space["tile_id"] = info["id"]
	#grid_space["tile_type"] = info["type"]
	#grid_space["card"]["type"] = "game_type"
	#if info["occupied"]:
		#grid_space["occupied"] = true
		#grid_space["occupant_id"] = info["occupant"]["id"]
		#grid_space["occupant_type"] = info["occupant"]["type"]
		#if info["occupant"]["name"]:
			#grid_space["card"]["card_name"].text = info["occupant"]["name"]
		#else:
			#grid_space["card"]["card_name"].text = ""
		#
		#grid_space["card"]["card_id"] = info["occupant"]["id"]
		#grid_space["card"]["source_type"] = info["occupant"]["subtype"]
		#grid_space["card"]["card_type"].text = info["occupant"]["subtype"].capitalize()
		#if info["occupant"]["subtype"] == "avatar":
			#grid_space.set_avatar(true)
		#else:
			#grid_space.set_avatar(false)
		#if info["occupant"]["exhausted"]:
			#grid_space["card_image"].modulate = Color.BLACK
		#else:
			#grid_space["card_image"].modulate = Color.WHITE
		#
		#var default_texture
		#match info["occupant"]["subtype"]:
			#"unit","avatar":
				#default_texture = load("res://assets/missing-images/none-unit.png")
			#"spell":
				#default_texture = load("res://assets/missing-images/none-spell.png")
			#"trap":
				#default_texture = load("res://assets/missing-images/none-trap.png")
			#"potion":
				#default_texture = load("res://assets/missing-images/none-potion.png")
		#var tex = await CardArtCache.get_texture_async(str(info["occupant"]["image"]),default_texture,true)
		#grid_space["card_image"].texture = tex
		#
	#else:
		#grid_space["occupied"] = false
		#grid_space["occupant_id"] = ""
		#grid_space["occupant_type"] = ""


func update_grid_space(info):
	#print("updating grid space")
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
	grid_space.update_tile(info)
	#grid_space["control"].visible = info["tile"]["occupied"]
	#grid_space["trap"].visible = info["tile"]["trapped"]
	#if info["tile"]["occupied"]:
		#if grid_space["occupied"] == true:
			##print(grid_space,info["tile"]["occupant"])
			#add_card_effects(grid_space,info["tile"]["occupant"])
			##print("Grid Space: ",grid_space)
		#grid_space["occupied"] = true
		#grid_space["occupant_id"] = info["tile"]["occupant"]["id"]
		##grid_space["occupant_type"] = info["tile"]["occupant"]["subtype"]
		#grid_space["occupant_type"] = info["tile"]["occupant"]["type"]
		#grid_space["abilities"] = info["tile"]["occupant"]["abilities"]
		##print(grid_space["abilities"])
		##print(info["tile"][["occupant"]])
		#if info["tile"]["occupant"]["name"]:
			#grid_space["card"]["card_name"].text = info["tile"]["occupant"]["name"]
		#else:
			#grid_space["card"]["card_name"].text = ""
		#grid_space["card"]["card_id"] = info["tile"]["occupant"]["id"]
		#grid_space["card"]["source_type"] = info["tile"]["occupant"]["subtype"]
		#grid_space["card"]["card_type"].text = info["tile"]["occupant"]["subtype"].capitalize()
		#if info["tile"]["occupant"]["subtype"] == "avatar":
			#grid_space.set_avatar(true)
		#else:
			#grid_space.set_avatar(false)
		#if info["tile"]["occupant"]["exhausted"]:
			##grid_space["control"].rotation_degrees = 35
			#grid_space["card_image"].modulate = Color.BLACK
		#else:
			##grid_space["control"].rotation_degrees = 0
			#grid_space["card_image"].modulate = Color.WHITE
		#var abilities = info["tile"]["occupant"]["abilities"]
		#for ability in abilities:
			#if abilities[ability]["name"] == "health":
				##print(abilities[ability])
				#var card_hp = abilities[ability]["value"]
				#grid_space["health"] = str(int(card_hp)) if card_hp > 0 else ""
				#grid_space["card"]["card_health"].text = str(int(card_hp)) if card_hp > 0 else ""
				#if abilities[ability]["value"] < abilities[ability]["max_value"]:
					#grid_space["card"]["card_health"].add_theme_color_override("font_color", Color.RED)
				#else:
					#grid_space["card"]["card_health"].add_theme_color_override("font_color", Color.WHITE)
			#elif abilities[ability]["name"] == "attack":
				#grid_space["card"]["card_attack"].text = str(int(abilities[ability]["value"]))
		#var default_texture
		#match info["tile"]["occupant"]["subtype"]:
			#"unit","avatar":
				#default_texture = load("res://assets/missing-images/none-unit.png")
			#"spell":
				#default_texture = load("res://assets/missing-images/none-spell.png")
			#"trap":
				#default_texture = load("res://assets/missing-images/none-trap.png")
			#"potion":
				#default_texture = load("res://assets/missing-images/none-potion.png")
		#var tex = await CardArtCache.get_texture_async(str(info["tile"]["occupant"]["image"]),default_texture,true)
		#grid_space["card_image"].texture = tex
	#elif info["tile"]["trapped"]:
		#print("*****")
		##print(info["tile"])
		##print("*****")
		##print("Trapped Tile")
	#else:
		##print(info["tile"])
		#grid_space["occupied"] = false
		#grid_space["occupant_id"] = ""
		#grid_space["occupant_type"] = ""

func add_card_effects(old_card,new_card):
	var effects = []
	#print("Old Card: ",old_card)
	#print("New Card: ",new_card)
	for ability in old_card["abilities"]:
		for second_ability in new_card["abilities"]:
			if ability == second_ability:
				#print(new_card["abilities"][ability])
				#if ability[""]
				#print("Ability: ",ability)
				var diff = new_card["abilities"][ability]["value"] - old_card["abilities"][ability]["value"]
				
				
				if diff != 0:
					var effect_dict = {
						"ability" : str(ability),
						"sign" : "+" if diff > 0 else "-",
						"diff_value" : abs(diff),
						"original_value" : old_card["abilities"][ability]["value"],
						"new_value" : new_card["abilities"][ability]["value"],
					}
					effects.push_front(effect_dict)
				#if new_card["abilities"][ability]["value"] != old_card["abilities"][ability]["value"]:
					#effects.push_front({"ability":str(ability),"value":0})
					
	#var effect = GAME_EFFECT.instantiate()
	#add_child(effect)
	#effect.add_to_queue(effects)
	#effect.global_position = (old_card.global_position + Vector2(135,135))
	old_card.game_effect_queue.add_to_queue(effects)

func update_unit(info):
	#print(info)
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
			#print("occupant: ",y)
			if info["unit"]["id"] == y.occupant_id:
				#print("occupant id: ",y.occupant_id)
				grid_space = y
				#print(grid_space)
	if grid_space == null:
		return
	#var grid_space = grid[info["unit"]["y"]][info["unit"]["x"]]
	#var grid_space = grid[info["unit"]["display_y"]][info["unit"]["display_x"]]
	#print(grid_space)
	#print("*****************************************")
	#print(info)
	#print("*****************************************")
	grid_space.update_unit(info["unit"])
	#grid_space["control"].visible = !info["unit"]["dead"]
	#if !info["unit"]["dead"]:
		#if grid_space["occupied"] == true:
			#add_card_effects(grid_space,info["unit"])
		#if info["unit"]["name"]:
			#grid_space["card"]["card_name"].text = info["unit"]["name"]
		#else:
			#grid_space["card"]["card_name"].text = ""
		#grid_space["card"]["card_id"] = info["unit"]["id"]
		#grid_space["card"]["card_type"].text = info["unit"]["subtype"].capitalize()
		#grid_space["card"]["type"] = "game_type"
		##print("exhausted: ",info["unit"]["exhausted"])
		#if info["unit"]["exhausted"]:
			##grid_space["control"].rotation_degrees = 35
			#grid_space["card_image"].modulate = Color.BLACK
		#else:
			##grid_space["control"].rotation_degrees = 0
			#grid_space["card_image"].modulate = Color.WHITE
		#grid_space["abilities"] = info["unit"]["abilities"]
		#var abilities = info["unit"]["abilities"]
		#for ability in abilities:
			#if abilities[ability]["name"] == "health":
				#var card_hp = abilities[ability]["value"]
				#grid_space["health"] = str(int(card_hp)) if card_hp > 0 else ""
				#grid_space["card"]["card_health"].text = str(int(card_hp)) if card_hp > 0 else ""
				#if abilities[ability]["value"] < abilities[ability]["max_value"]:
					#grid_space["card"]["card_health"].add_theme_color_override("font_color", Color.RED)
					#grid_space["card"]["card_health"].add_theme_color_override("font_color", Color.RED)
				#else:
					#grid_space["card"]["card_health"].add_theme_color_override("font_color", Color.WHITE)
			#elif abilities[ability]["name"] == "attack":
				#grid_space["card"]["card_attack"].text = str(int(abilities[ability]["value"]))
	#else:
		#grid_space["card"]["card_id"] = 0
		#grid_space["card"]["type"] = ""
