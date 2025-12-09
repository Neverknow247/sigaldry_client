extends Control

var scene_name = "rewards"

var stats = Stats

const REWARD_BUTTON = preload("res://items/reward_button.tscn")
const REWARD_LABEL = preload("res://items/reward_label.tscn")

@onready var color_background: ColorRect = $color_background
@onready var rewards: VBoxContainer = $h_box_container/rewards_container/rewards_scroll/rewards
@onready var templates: VBoxContainer = $h_box_container/templates_container/template_scroll/templates
@onready var components: VBoxContainer = $h_box_container/components_container/components_scroll/components

signal close_rewards
signal selected_reward(_id, _amount)

func _ready() -> void:
	color_background.color = stats.background_color

func _on_back_button_pressed() -> void:
	close_rewards.emit()

func reset():
	for child in templates.get_children():
		templates.remove_child(child)
		child.queue_free()
	for child in components.get_children():
		components.remove_child(child)
		child.queue_free()

func set_up_rewards(payload):
	#print(payload)
	for child in rewards.get_children():
		rewards.remove_child(child)
		child.queue_free()
	for reward in payload["containers"]:
		#print(reward)
		var new_reward = REWARD_BUTTON.instantiate()
		rewards.add_child(new_reward)
		new_reward["button"].text = "X" + str(int(reward["available"])) + " " + reward["name"]
		new_reward["spin_box"].max_value = reward["available"]
		new_reward["reward_id"] = reward["key"]
		new_reward.connect("selected_reward",select_reward)

func select_reward(_id, _amount):
	selected_reward.emit(_id,_amount)

func show_rewards(payload):
	reset()
	var template_rewards = payload["rewards"]["templates"]
	template_rewards.shuffle()
	print(payload)
	for reward in template_rewards:
	#for reward in payload["rewards"]["templates"]:
		var new_reward = REWARD_LABEL.instantiate()
		templates.add_child(new_reward)
		new_reward.label.text = reward["name"]
		new_reward.reward_shape_grid.create_template_shapes(reward["component_grid"])
		new_reward.set_rarity_label(reward["rarity"])
	var component_rewards = payload["rewards"]["components"]
	component_rewards.shuffle()
	for reward in component_rewards:
	#for reward in payload["rewards"]["components"]:
		var new_reward = REWARD_LABEL.instantiate()
		components.add_child(new_reward)
		new_reward.label.text = reward["name"]
		new_reward.reward_shape_grid.create_component_shapes(reward)
		new_reward.set_rarity_label(reward["rarity"])
