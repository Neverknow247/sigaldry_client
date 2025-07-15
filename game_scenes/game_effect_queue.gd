extends Control

const effect_label = preload("res://game_scenes/effect_label.tscn")

@onready var effect_node = $effect_node
@onready var effect_timer = $effect_timer

var all_effects = []
var effect_messages = {
	"health" : null,
	"armor" : null,
}


func add_to_queue(effects):
	for effect in effects:
		all_effects.push_back(effect)
	if effect_timer.time_left <= 0:
		push_new_effect()
		#effects_string+= str(effect) + ", "

func push_new_effect():
	if all_effects.size() > 0:
		var new_effect = effect_label.instantiate()
		effect_node.add_child(new_effect)
		new_effect.text = str(all_effects[0])
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
