extends Control

const effect_label = preload("res://game_scenes/effect_label.tscn")

@onready var effect_node = $effect_node
@onready var effect_timer = $effect_timer

const RED = "ff0000"
const GREEN = "00ff00"

var all_effects = []
var effect_messages = {
	"health" : null,
	"armor" : null,
	"weak" : null,
}


func add_to_queue(effects):
	for effect in effects:
		all_effects.push_back(effect)
	if effect_timer.time_left <= 0:
		push_new_effect()
		#effects_string+= str(effect) + ", "


#var effect_dict = {
	#"ability" : str(ability),
	#"sign" : "+/-",
	#"diff_value" : diff,
	#"original_value" : old_card["abilities"][ability]["value"],
	#"new_value" : new_card["abilities"][ability]["value"]
#}


func push_new_effect():
	if all_effects.size() > 0:
		var new_effect = effect_label.instantiate()
		effect_node.add_child(new_effect)
		if effect_messages.has(str(all_effects[0]["ability"])):
			new_effect.text = str(all_effects[0]["ability"]).capitalize()+" "+str(all_effects[0]["sign"])+str(int(all_effects[0]["diff_value"]))
			new_effect.text += "\n" + str(all_effects[0]["original_value"])+" -> "+str(all_effects[0]["new_value"])
		new_effect.self_modulate = Color(RED) if str(all_effects[0]["sign"]) == "-" else Color(GREEN)
		new_effect.position = Vector2(new_effect.size/2) * -1
		effect_timer.start()
	#queue_free()
	#$label.text = effects_string
	#$timer.start()
	
	
	#Health -2 (10)
	#Bleed +1 (3)

func _on_effect_timer_timeout():
	for child in effect_node.get_children():
		effect_node.remove_child(child)
		child.queue_free()
	all_effects.pop_at(0)
	check_effect_queue()

func check_effect_queue():
	if all_effects.size() > 0:
		push_new_effect()
