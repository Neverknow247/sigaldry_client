extends Control

var sounds = Sounds
var stats = Stats
var utils = Utils

const ARE_YOU_SURE_POPUP = preload("res://items/are_you_sure_popup.tscn")
const SETTINGS_POPUP = preload("res://items/settings_popup.tscn")
const STANDARD_MATERIALS_1 = preload("res://assets/art/icons/larger_icons/Icon_Currency_GoldCoin.png")
const STANDARD_MATERIALS_2 = preload("res://assets/art/icons/larger_icons/Icon_Currency_GoldCoin2.png")

#const RANK_LEAF = preload("res://assets/art/icons/rank_leaf.png")
#const RANK_FIRE = preload("res://assets/art/icons/rank_fire.png")
#const RANK_WATER = preload("res://assets/art/icons/rank_water.png")
#const RANK_STAR = preload("res://assets/art/icons/rank_star.png")
#var all_ranks = [RANK_LEAF,RANK_FIRE,RANK_WATER,RANK_STAR]
const PVE_RANK_1 = preload("res://assets/art/hud_icons/pve_1.png")
const PVE_RANK_2 = preload("res://assets/art/hud_icons/pve_2.png")
const PVE_RANK_3 = preload("res://assets/art/hud_icons/pve_3.png")
const PVE_RANK_4 = preload("res://assets/art/hud_icons/pve_4.png")
const PVE_RANK_5 = preload("res://assets/art/hud_icons/pve_5.png")
var all_pve_ranks = [PVE_RANK_1,PVE_RANK_2,PVE_RANK_3,PVE_RANK_4,PVE_RANK_5]
var highest_rank = 9

const PVP_RANK_1 = preload("res://assets/art/hud_icons/pvp_1.png")
const PVP_RANK_2 = preload("res://assets/art/hud_icons/pvp_2.png")
const PVP_RANK_3 = preload("res://assets/art/hud_icons/pvp_3.png")
const PVP_RANK_4 = preload("res://assets/art/hud_icons/pvp_4.png")
const PVP_RANK_5 = preload("res://assets/art/hud_icons/pvp_5.png")
var all_pvp_ranks = [PVP_RANK_1,PVP_RANK_2,PVP_RANK_3,PVP_RANK_4,PVP_RANK_5]

@onready var pve_rank_icon: TextureRect = $player_info/pve_rank_icon
@onready var pve_rank_label: Label = $player_info/pve_rank_icon/pve_rank_label
@onready var pve_button: Button = $player_info/pve_rank_icon/pve_button

@onready var pvp_rank_icon: TextureRect = $player_info/pvp_rank_icon
@onready var pvp_rank_label: Label = $player_info/pvp_rank_icon/pvp_rank_label
@onready var pvp_button: Button = $player_info/pvp_rank_icon/pvp_button

@onready var fusion_number: Label = $resources/fusion_crystals/fusion_number

@onready var screen_name_label: Label = $player_info/screen_name_label
@onready var standard_icon: TextureRect = $resources/materials/standard_materials/standard_icon
@onready var standard_number: Label = $resources/materials/standard_materials/standard_number
@onready var premium_number: Label = $resources/materials/premium_materials/premium_number

@onready var cancel_button: Button = $menu_buttons/cancel_button
@onready var home_button: Button = $menu_buttons/home_button
@onready var builder_button: Button = $menu_buttons/builder_button
@onready var editor_button: Button = $menu_buttons/editor_button
@onready var collection_button: Button = $menu_buttons/collection_button
@onready var battle_button: Button = $menu_buttons/battle_button

@onready var profile_button: Button = $main_buttons/profile_button
@onready var rewards_button: Button = $main_buttons/rewards_button
@onready var shop_button: Button = $main_buttons/shop_button

@onready var all_buttons = [
	cancel_button, home_button, profile_button, collection_button,
	builder_button, editor_button, rewards_button, battle_button,
	shop_button
]
@onready var all_home_buttons = [
	home_button, profile_button, collection_button,
	builder_button, editor_button, rewards_button,
	battle_button, shop_button
]

@onready var reward_notification: TextureRect = $main_buttons/rewards_button/control/reward_notification
@onready var settings_dropdown: PopupMenu = $main_buttons/settings/settings_dropdown

signal user_change_account

signal cancel
signal home
signal profile
signal collection
signal build
signal edit
signal rewards
signal battle
signal pve_battle
signal pvp_battle
signal shop

signal back
signal logout
signal concede

func _ready() -> void:
	reset_settings()
	stats.stats_modified.connect(stats_modified)

func reset_settings():
	settings_dropdown.clear()
	settings_dropdown.size.y = 0
	settings_dropdown.add_item("Settings",3)
	settings_dropdown.add_item("Logout",1)
	settings_dropdown.add_item("Quit",0)

func stats_modified(_data):
	match _data["stat"]:
		"pve_xp":
			user_change_account.emit()
		"pve_level":
			update_pve_level(_data["value"])
		"pvp_xp":
			user_change_account.emit()
		"pvp_level":
			update_pvp_level(_data["value"])

func update_pve_level(_level):
	if _level/highest_rank > all_pve_ranks.size()-1:
		pve_rank_icon.texture = PVE_RANK_5
		pve_button.tooltip_text =\
		"PVE" + "\n" +\
		"Tier: MAX" + "\n" +\
		"Rank: " + str((_level%highest_rank)+1)
		pve_rank_label.text = str(_level-((all_pve_ranks.size()-1)*highest_rank)+1)
	else:
		pve_rank_icon.texture = all_pve_ranks[_level/highest_rank]
		pve_button.tooltip_text =\
		"PVE" + "\n" +\
		"Tier: " + str(_level/highest_rank + 1) + "\n" +\
		"Rank: " + str((_level%highest_rank)+1)
		pve_rank_label.text = str((_level%highest_rank)+1)

func update_pvp_level(_level):
	if _level/highest_rank > all_pvp_ranks.size()-1:
		pvp_rank_icon.texture = PVP_RANK_5
		pvp_button.tooltip_text =\
		"PVP" + "\n" +\
		"Tier: MAX" + "\n" +\
		"Rank: " + str((_level%highest_rank)+1)
		pvp_rank_label.text = str(_level-((all_pvp_ranks.size()-1)*highest_rank)+1)
	else:
		pvp_rank_icon.texture = all_pvp_ranks[_level/highest_rank]
		pvp_button.tooltip_text =\
		"PVP" + "\n" +\
		"Tier: " + str(_level/highest_rank + 1) + "\n" +\
		"Rank: " + str((_level%highest_rank)+1)
		pvp_rank_label.text = str((_level%highest_rank)+1)

func update_player(payload):
	if payload:
		print(payload)
		set_screen_name(payload["screen_name"])
		set_levels()
		standard_number.text = format_number_with_commas(payload["standard_currency"])
		if payload["standard_currency"] >= 1000000:
			standard_icon.texture = STANDARD_MATERIALS_2
		else:
			standard_icon.texture = STANDARD_MATERIALS_1
		premium_number.text = format_number_with_commas(payload["premium_currency"])
		fusion_number.text = str(int(payload["fusion_currency"]))
		#standard_number.text = str(int(payload["standard_currency"]))
		#premium_number.text = str(int(payload["premium_currency"]))

func check_rewards(payload):
	if payload["containers"].size() > 0:
		reward_notification.set_notifications_enabled(true)
	else:
		reward_notification.set_notifications_enabled(false)

func update_scene(new_scene_name):
	print("NEW SCENE NAME: ",new_scene_name)
	match new_scene_name:
		"menu":
			cancel_button.hide()
			for button in all_home_buttons:
				button.show()
		"wrong_version","login","register","card_select":
			for button in all_buttons:
				button.hide()
		"deck_select":
			cancel_button.show()
			for button in all_home_buttons:
				button.hide()
		"waiting":
			cancel_button.show()
			for button in all_home_buttons:
				button.hide()
		"game":
			for button in all_buttons:
				button.hide()
			settings_dropdown.clear()
			settings_dropdown.add_item("Settings",3)
			settings_dropdown.add_item("Concede",10)
			settings_dropdown.add_item("Logout",1)
			settings_dropdown.add_item("Quit",0)
			#settings_dropdown.
		"game_finished":
			reset_settings()
			#settings_dropdown.remove_item(settings_dropdown.get_item_index(10))
		_:
			cancel_button.hide()
			for button in all_home_buttons:
				button.show()

func set_screen_name(_screen_name):
	screen_name_label.text = _screen_name
	stats["logged_in_user"] = _screen_name

func set_levels():
	update_pve_level(stats["pve_level"])
	update_pvp_level(stats["pvp_level"])

func _on_back_button_pressed() -> void:
	back.emit()

func _on_settings_button_pressed() -> void:
	settings_dropdown.show()

func _on_settings_dropdown_index_pressed(index: int) -> void:
	#print("DROP DOWN SELECT: ",settings_dropdown.get_item_text(index))
	match settings_dropdown.get_item_text(index):
		"Settings":
			sounds.play_sound("click", 1, -15)
			utils.instantiate_popup_on_world(SETTINGS_POPUP)
		"Logout":
			stats["save_data"]["remember_me"]["username"] = ""
			stats["save_data"]["remember_me"]["password"] = ""
			SaveAndLoad.save_all()
			logout.emit()
		"Quit":
			logout.emit()
			get_tree().quit()
		"Concede":
			#print("concede?")
			var popup_window = utils.instantiate_popup_on_world(ARE_YOU_SURE_POPUP)
			popup_window.are_you_sure_label.text = "are you sure you want to concede?"
			popup_window.connect("yes",concede.emit)
			#concede.emit()
	#print(index)

func quit_game(payload):
	utils.j_print(payload)
	if payload["loser_name"] == "Computer" || payload["winner_name"] == "Computer":
		stats["game_type"] = "pve"
	else:
		stats["game_type"] = "pvp"
	if payload["is_draw"]:
		stats[stats["game_type"]+"_xp"] += 1
	elif payload["winner_name"] == stats["logged_in_user"]:
		stats[stats["game_type"]+"_xp"] += 2
	else:
		stats[stats["game_type"]+"_xp"] -= 1

func format_number_with_commas(number: int) -> String:
	var num_str: String = str(abs(number))
	var result: String = ""
	var count: int = 0
	# Loop through digits from right to left
	for i in range(num_str.length() - 1, -1, -1):
		result = num_str[i] + result
		count += 1
		# Add a comma every three digits, except before the first digit
		if count % 3 == 0 and i != 0:
			result = "," + result
			
	# Add the negative sign back if the original number was negative
	if number < 0:
		result = "-" + result
	return result

func _on_cancel_button_pressed() -> void:
	sounds.play_sound("click", 1, -15)
	cancel.emit()

func _on_home_button_pressed() -> void:
	sounds.play_sound("click", 1, -15)
	home.emit()

func _on_profile_button_pressed() -> void:
	sounds.play_sound("click", 1, -15)
	pass # Replace with function body.

func _on_collection_button_pressed() -> void:
	sounds.play_sound("click", 1, -15)
	collection.emit()

func _on_rewards_button_pressed() -> void:
	sounds.play_sound("click", 1, -15)
	rewards.emit()

func _on_builder_button_pressed() -> void:
	sounds.play_sound("click", 1, -15)
	build.emit()

func _on_editor_button_pressed() -> void:
	sounds.play_sound("click", 1, -15)
	edit.emit()

func _on_battle_button_pressed() -> void:
	sounds.play_sound("click", 1, -15)
	battle.emit()

func _on_pve_button_pressed() -> void:
	sounds.play_sound("click", 1, -15)
	pve_battle.emit()

func _on_pvp_button_pressed() -> void:
	sounds.play_sound("click", 1, -15)
	pvp_battle.emit()

func _on_shop_button_pressed() -> void:
	sounds.play_sound("click", 1, -15)
	shop.emit()
