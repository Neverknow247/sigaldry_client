extends Control

var scene_name = "menu"

var stats = Stats

const REWARD = preload("res://items/reward.tscn")

@onready var background_color: ColorRect = $background/background_color
@onready var game_finished_screen = $game_finished_screen
@onready var rewards_button: Button = $rewards_button

signal logout
signal search_for_pvp_game
signal search_for_pve_game
signal new_game
signal view_all_cards
signal start_card_builder
signal start_card_editor
signal start_deck_editor
signal start_rewards_screen
signal button_1
signal button_2
signal button_3

func _ready():
	background_color.color = stats.background_color

func _on_logout_button_pressed():
	stats["save_data"]["remember_me"]["username"] = ""
	stats["save_data"]["remember_me"]["password"] = ""
	SaveAndLoad.save_all()
	logout.emit()

func _on_quit_button_pressed():
	logout.emit()
	get_tree().quit()

func _on_search_for_a_pvp_game_button_pressed():
	search_for_pvp_game.emit()

func _on_search_for_a_pve_game_pressed():
	search_for_pve_game.emit()

func _on_view_cards_button_pressed():
	view_all_cards.emit()

func _on_card_builder_button_pressed():
	start_card_builder.emit()
	
func _on_card_editor_button_pressed() -> void:
	start_card_editor.emit()

func _on_deck_editor_button_pressed():
	start_deck_editor.emit()

func quit_game(payload):
	game_finished_screen.quit_game(payload)

#func show_rewards(payload):
	#game_finished_screen.show_rewards(payload)

func update_rewards(payload):
	print(payload)
	for child in $rewards_box.get_children():
		$rewards_box.remove_child(child)
		child.queue_free()
	for reward in payload["rewards"]:
		var new_reward = REWARD.instantiate()
		$rewards_box.add_child(new_reward)
		new_reward.component_name.text = payload["rewards"][reward]["component"]["description"]
		new_reward.count_label.text = "X"+str(int(payload["rewards"][reward]["count"]))
		new_reward.component_shape_grid.create_component_shapes(payload["rewards"][reward]["component"])
		print(reward)

func check_rewards(payload):
	return
	#print(payload)
	if payload["containers"].size() > 0:
		rewards_button.show()
	else:
		rewards_button.hide()

func _on_rewards_button_pressed() -> void:
	start_rewards_screen.emit()

func _on_build_button_pressed() -> void:
	start_card_builder.emit()

func _on_main_button_pressed() -> void:
	OS.shell_open("https://discord.gg/54mqjQpK6p")

func _on_fight_button_pressed() -> void:
	new_game.emit()

func _on_button_1_pressed() -> void:
	button_1.emit()

func _on_button_2_pressed() -> void:
	button_2.emit()

func _on_button_3_pressed() -> void:
	button_3.emit()
