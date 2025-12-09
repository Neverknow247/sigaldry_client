class_name DeckmasterClient extends Node

var stats = Stats
var utils = Utils
#var KEYWORD_GLOSSARY = KeyWordGlossary

var client = SocketIOClient
var backendURL: String

#var card_art_cache = CardArtCache.new()
var card_art_cache = CardArtCache

@onready var transition = $transition

@onready var all_scenes = $scenes.get_children()

@onready var tooltips: Control = $tooltips

@onready var hud: Control = $hud

#@onready var wrong_version_screen: Control = $v_box_container/scenes/wrong_version_screen
#@onready var login_screen: Control = $v_box_container/scenes/login_screen
#@onready var register_screen: Control = $v_box_container/scenes/register_screen
#@onready var main_menu: Control = $v_box_container/scenes/main_menu
#@onready var deck_select_screen: Control = $v_box_container/scenes/deck_select_screen
#@onready var waiting_for_game_screen: Control = $v_box_container/scenes/waiting_for_game_screen
#@onready var card_select_screen: Control = $v_box_container/scenes/card_select_screen
#@onready var game_select_screen: Control = $v_box_container/scenes/game_select_screen
#@onready var game_screen: Control = $v_box_container/scenes/game_screen
#@onready var game_finished_screen: Control = $v_box_container/scenes/game_finished_screen
#@onready var card_view_screen: Control = $v_box_container/scenes/card_view_screen
#@onready var card_builder: Control = $v_box_container/scenes/card_builder
#@onready var card_editor: Control = $v_box_container/scenes/card_editor
#@onready var deck_editor: Control = $v_box_container/scenes/deck_editor
#@onready var rewards_screen: Control = $v_box_container/scenes/rewards_screen





@onready var wrong_version_screen: Control = $scenes/wrong_version_screen
@onready var login_screen: Control = $scenes/login_screen
@onready var register_screen: Control = $scenes/register_screen
@onready var main_menu: Control = $scenes/main_menu
@onready var deck_select_screen: Control = $scenes/deck_select_screen
@onready var waiting_for_game_screen: Control = $scenes/waiting_for_game_screen
@onready var card_select_screen: Control = $scenes/card_select_screen
@onready var game_select_screen: Control = $scenes/game_select_screen
@onready var game_screen: Control = $scenes/game_screen
@onready var game_finished_screen: Control = $scenes/game_finished_screen
@onready var card_view_screen: Control = $scenes/card_view_screen
@onready var card_builder: Control = $scenes/card_builder
@onready var card_editor: Control = $scenes/card_editor
@onready var deck_editor: Control = $scenes/deck_editor
@onready var rewards_screen: Control = $scenes/rewards_screen

var current_scene = ""

func _ready():
	# prepare URL
	
	#backendURL = "http://75.219.184.116:3000/socket.io"
	#backendURL = "http://172.20.10.6:3000/socket.io"
	
	#aws
	backendURL = "http://3.139.99.80/socket.io"
	#ethernet
	#backendURL = "http://192.168.1.151:3000/socket.io"
	#wifi
	#backendURL = "http://172.28.48.1:3000/socket.io"

	# initialize client
	client = SocketIOClient.new(backendURL, {"token": "MY_AUTH_TOKEN"})

	# this signal is emitted when the socket is ready to connect
	client.on_engine_connected.connect(on_socket_ready)

	# this signal is emitted when socketio server is connected
	client.on_connect.connect(on_socket_connect)

	# this signal is emitted when socketio server sends a message
	client.on_event.connect(on_socket_event)

	# add client to tree to start websocket
	add_child(client)
	#add_child(card_art_cache)
	card_art_cache.set_request_sender(func(req: Dictionary) -> void:
		var ev: String = String(req.get("type", ""))
		var dat = req.get("data", {})
		if ev == "":
			push_warning("CardArtCache tried to send without a type")
			return
		client.socketio_send(ev,dat)
	)
	utils.tooltips = tooltips

func _exit_tree():
	# optional: disconnect from socketio server
	client.socketio_disconnect()

func on_socket_ready(_sid: String):
	# connect to socketio server when engine.io connection is ready
	client.socketio_connect()

func on_socket_connect(_payload: Variant, _name_space, error: bool):
	if error:
		push_error("Failed to connect to backend! Error: ",error)
	else:
	
		print("Socket connected")


func on_socket_event(event_name: String, payload: Variant, _name_space):
	#print("Received Event: ", event_name, " ", payload)
	print("Received Event: ", event_name)
	#print(payload)
	if payload:
		print(payload["sequence"])
	# hide login_screen and show basic menu
	match event_name:
		"exception":
			if payload["message"].contains("You must be logged in"):
				change_scene("login")
			print(payload)
			#show_error(payload)
			#print(payload)
			print("Error")
		"get-glossary":
			KeyWordGlossary.set_glossary(payload)
		"update-player-info":
			hud.update_player(payload["def"])
		"login":
			if ProjectSettings.get_setting("application/config/version") != payload["server_version"]:
				change_scene("wrong_version")
				return
			hud.update_player(payload)
			KeyWordGlossary.set_glossary(payload)
			#print(payload)
			change_scene("menu")
			login_screen.reset_screen()
			#card_art_cache.set_request_sender()
		"logout":
			change_scene("login")
		"register-success":
			change_scene("login")
			register_screen.reset_screen()
		"show-lobby":
			#print(payload)
			change_scene("menu")
		"card-builder-update-templates":
			card_builder.load_build_templates(payload)
		"start-card-builder":
			change_scene("card_builder")
			card_builder.reset_card_builder()
		"close-card-builder":
			card_builder.close()
			change_scene("menu")
		"card-builder-update-components":
			#for component in payload["components"]:
				#print(component)
			card_builder.load_builder_components(payload)
			#load_builder_components(payload)
		"card-builder-update-grid":
			card_builder.card_builder_update_grid(payload)
		"card-builder-update-card":
			card_builder.card_builder_update_card(payload)
		"builder-view-cards":
			card_builder.view_cards(payload)
		"start-card-editor":
			change_scene("card_editor")
			card_editor.add_cards(payload)
		"imagegen-get-unit-requirements":
			card_editor.card_image_edit.set_unit_requirements(payload)
		"imagegen-get-unit-options":
			card_editor.card_image_edit.set_unit_options(payload)
		"imagegen-unit-image-started":
			show_error({"message":"Image Started"})
			client.socketio_send("card-view-all",{
			"on_success":"start-card-editor",
			"query":{
				#"subtype":"unit",
				#"image_status":"none",
				#"name_status":"none"
				"image_or_name_status":"none",
				#"unique_key":""
				}
			})
		"imagegen-unit-image-complete":
			show_error({"message":"Image Complete"})
		"imagegen-unit-image-failed":
			show_error({"message":"Image Failed"})
		"validate-card-name":
			show_error({"message":"Card Name Validated"})
			card_editor.card_name_edit.card_name_validated(payload)
		"save-card-name":
			show_error({"message":"Card Name Saved"})
			client.socketio_send("card-view-all",{
			"on_success":"start-card-editor",
			"query":{
				#"subtype":"unit",
				#"image_status":"none",
				#"name_status":"none"
				"image_or_name_status":"none",
				#"unique_key":""
				}
			})
		
		
		"card-view-all":
			change_scene("card_view")
			card_view_screen.add_cards(payload)
			#print(payload)
		#"editor-view-cards":
			#change_scene("card_view")
			#card_view_screen.add_cards(payload)
		"card-view-units":
			print(payload)
		"deck-editor-update-cards-in-deck":
			deck_editor.update_cards_in_deck(payload)
		"deck-editor-update-cards-not-in-deck":
			deck_editor.update_cards_not_in_deck(payload)
		"editor-view-units":
			deck_editor.update_cards_unit_only(payload)
		"deck-editor-start-new-deck":
			deck_editor.start_new_deck(payload)
		#"deck-editor-new-deck-units":
			#deck_editor.update_cards_unit_only(payload)
			#print(payload)
		#"editor-done":
			#deck_editor.add_avatar()
		"start-deck-editor":
			deck_editor.start_deck_editor(payload)
		"get_info_deck_editor_card_avatar_selected":
			deck_editor.card_avatar_selected(payload)
		"deck-editor-update-decks":
			change_scene("deck_editor")
			deck_editor.update_decks(payload)
		"close-deck-editor":
			change_scene("menu")
		
		#game events
		"new-game-options":
			game_select_screen.set_up_pve(payload)
		"select-deck":
			change_scene("deck_select")
			card_select_screen.reset()
			deck_select_screen.add_decks(payload)
		"waiting":
			change_scene("waiting")
			waiting_for_game_screen.waiting(payload)
		"update-unit":
			game_screen.update_unit(payload)
		"select-cards":
			change_scene("card_select")
			card_select_screen.update_cards(payload)
		"select-cards-timer-update":
			card_select_screen.countdown(payload)
		"update-selected-cards":
			card_select_screen.update_cards(payload)
		"update-turn":
			#change_scene("game")
			game_screen.update_turn(payload)
		"add-combat-log":
			game_screen.add_combat_log(payload)
		"update-energy":
			game_screen.update_energy(payload)
		"join-game":
			#print(payload["id"])
			game_screen.join_game(payload)
		"update-players":
			#print(payload)
			game_screen.update_players(payload)
		"update-tiles":
			#for i in payload:
				#print(i)
			print(payload["my_avatar_id"])
		"update-tile":
			game_screen.update_tile(payload)
		"show-action":
			game_screen.show_action(payload)
		"info-request":
			game_screen.info_request(payload)
		"get-info":
			game_screen.info_request(payload)
		"get_info_card_image_edit":
			card_editor.card_image_edit.get_info_card_image_edit(payload)
		"get_info_card_name_edit":
			card_editor.card_name_edit.get_info_card_name_edit(payload)
		"start-game":
			change_scene("game")
		"choose-target":
			game_screen.choose_target(payload)
		"quit-game":
			game_screen.quit_game(payload)
			change_scene("game_finished")
			game_finished_screen.quit_game(payload)
			#main_menu.quit_game(payload)
		"rewards-get-containers":
			rewards_screen.set_up_rewards(payload)
			main_menu.check_rewards(payload)
			#print(JSON.stringify(payload, "\t"))
		"rewards-open-containers":
			rewards_screen.show_rewards(payload)
			client.socketio_send("rewards-get-containers")
			#print(JSON.stringify(payload, "\t"))
		"rewards-earned-containers":
			print(JSON.stringify(payload, "\t"))
		#"card-view-all":
			#print(payload)
		"get-card-image-files","get-card-image-keys","get-opponent-card-image-keys":
			if typeof(payload) == TYPE_DICTIONARY:
				card_art_cache.route_server_message({"type": event_name, "data": payload})
			else:
				card_art_cache.route_server_message({"type": event_name, "data": {}})
		_:
			print("Unknown Event: ", event_name)

func show_error(payload):
	if payload["message"]:
		$error_label.text = payload["message"]
		await get_tree().create_timer(4).timeout
		$error_label.text = ""

func change_scene(new_scene_name = ""):
	current_scene = new_scene_name
	hud.update_scene(new_scene_name)
	if new_scene_name == "menu":
		client.socketio_send("rewards-get-containers")
	transition.fade_out()
	utils.clear_tooltips()
	await get_tree().create_timer(stats.transition_time).timeout
	for scene in all_scenes:
		#print(scene.scene_name)
		if scene.scene_name:
			if scene.scene_name == new_scene_name:
				scene.show()
			else:
				scene.hide()
	match new_scene_name:
		"login","register","wrong_version":
			hud.hide()
		_:
			hud.show()
	await get_tree().create_timer(stats.transition_time).timeout
	transition.fade_in()

func _on_login_screen_change_screen_to_register():
	change_scene("register")

func _on_register_screen_change_screen_to_login():
	change_scene("login")

func _on_card_view_screen_exit_menu():
	change_scene("menu")


func _on_hud_logout() -> void:
	client.socketio_send("logout")

func _on_hud_concede() -> void:
	client.socketio_send("concede-game")

func _on_main_menu_logout():
	client.socketio_send("logout")


#CARD BUILDER FUNCTIONS
func _on_card_builder_back_to_menu():
	client.socketio_send("close-card-builder")

func _on_card_builder_template_selected(id):
	print("selecting builder template, id: ",id)
	client.socketio_send("card-builder-select-template",{'template_id':id})

func _on_card_builder_place_component():
	client.socketio_send("card-builder-set-component")

func _on_card_builder_component_removed():
	client.socketio_send("card-builder-remove-component",{})

func _on_card_builder_component_selected(id):
	client.socketio_send("card-builder-add-component",{'component_id':id})

func _on_card_builder_change_name(card_name):
	client.socketio_send("builder-change-name",{'name':card_name})

func _on_card_builder_save_card():
	client.socketio_send("card-builder-save-card")
	client.socketio_send("close-card-builder")

func _on_card_builder_piece_rotate(direction: Variant) -> void:
	client.socketio_send("card-builder-rotate-component",direction)

func _on_card_builder_piece_flip() -> void:
	client.socketio_send("card-builder-flip-component",{"direction":"horizontal"})

func _on_card_builder_move_set(data):
	client.socketio_send("card-builder-add-component",data)

func _on_card_builder_undo():
	client.socketio_send("card-builder-unset-component",{})

func _on_card_builder_compare_card_select():
	client.socketio_send("view-cards",{"unit_only":false,"builder":true})

func _on_card_builder_restart():
	client.socketio_send("start-card-builder")

func _on_login_screen_login(username, password):
	client.socketio_send("login", {'username':username,'password':password})

func _on_register_screen_register(username, screen_name, email, password):
	client.socketio_send("register",{'username':username, 'email_address':email,'password':password,'screen_name':screen_name})

func _on_main_menu_search_for_pvp_game():
	#change_scene("game_select")
	#game_select_screen.set_up_pvp()
	client.socketio_send("start-looking-for-game",{
		"min_rarity": 1,
		"max_rarity": 5,
		"match_type": "pvp",
		"pvp_timeout": 60,
		"region": 6
	})

func _on_main_menu_search_for_pve_game():
	#change_scene("game_select")
	#client.socketio_send("new-game-options")
	#return
	#game_select_screen.set_up_pve()
	client.socketio_send("start-looking-for-game",{
		"min_rarity": 1,
		"max_rarity": 5,
		"match_type": "pve",
		#"pve_deck_id": ,
		#"region": 6
	})

func _on_main_menu_view_all_cards():
	client.socketio_send("card-view-all",{
		"query":{
			#"subtype":"unit",
			#"image_status":"none",
			#"name_status":"none"
			#"image_or_name_status":"none",
			#"unique_key":""
			}
		})

func _on_main_menu_start_card_builder():
	client.socketio_send("start-card-builder")


#Deck Editor Functions
func _on_main_menu_start_deck_editor():
	client.socketio_send("start-deck-editor")

func _on_deck_editor_deck_selected(id):
	client.socketio_send("deck-editor-select-deck",{"deck_id":id})

func _on_deck_editor_close_deck_editor():
	client.socketio_send("close-deck-editor")

func _on_deck_editor_add_card_to_deck(id):
	client.socketio_send("deck-editor-add-card",{"card_id":id,"is_avatar":false})

#func _on_deck_editor_add_avatar_to_deck(id):
	#client.socketio_send("editor-add-card",{"card_id":id,"is_avatar":true})

func _on_deck_editor_remove_card_from_deck(id):
	client.socketio_send("deck-editor-remove-card",{"card_id":id})

func _on_deck_editor_change_deck_name(deck_name):
	client.socketio_send("editor-change-name",{'name':deck_name})

func _on_deck_editor_delete_deck():
	client.socketio_send("deck-editor-delete-deck",{})

#func _on_deck_editor_create_new_deck(deck_name):
	#client.socketio_send("editor-add-deck",{"name":deck_name})

func _on_deck_editor_start_create_new_deck():
	client.socketio_send("card-view-all",{
		"on_success" : "deck-editor-start-new-deck",
		"query" : {
			"subtype" : "avatar",
			#"image_status":"none",
			#"name_status":"none"
			#"image_or_name_status":"none",
			#"unique_key":""
		}
	})

func _on_deck_editor_show_units_only():
	client.socketio_send("card-view-all",{
		"on_success":"deck-editor-new-deck-units",
		"query":{
			"subtype":"unit",
			#"image_status":"none",
			#"name_status":"none"
			#"image_or_name_status":"none",
			#"unique_key":""
			}
		})
	#client.socketio_send("card-view-units",{"unit_only":true,"builder":false})
	
	#client.socketio_send("view-cards",{"unit_only":true,"builder":false})

func _on_deck_editor_create_new_deck(deck_name,avatar_id):
	client.socketio_send("deck-editor-add-avatar-deck",{"name":deck_name,"avatar_id":avatar_id})
	#client.socketio_send("editor-add-avatar-deck",{"name":deck_name,"avatar_id":avatar_id})

#Game Functions

func _on_game_select_screen_close_game_select() -> void:
	change_scene("menu")

func _on_deck_select_screen_select_deck(id):
	client.socketio_send("deck-selected-for-new-game",{"deck_id":str(id)})

func _on_deck_select_screen_cancel_deck_select():
	client.socketio_send("cancel-select-deck")

func _on_waiting_for_game_screen_cancel_validation():
	client.socketio_send("cancel-waiting-for-validation")

func _on_waiting_for_game_screen_cancel_game():
	client.socketio_send("cancel-waiting-for-game")

func _on_card_select_screen_card_select(id):
	client.socketio_send("select-card",{"card_id":str(id)})

func _on_card_select_screen_card_select_done():
	client.socketio_send("select-cards-complete")

func _on_game_screen_end_turn():
	client.socketio_send("end-turn")

func _on_game_screen_concede():
	client.socketio_send("concede-game")

func _on_game_screen_card_selected(play_info):
	client.socketio_send("play",play_info)

func _on_game_screen_get_info(data):
	client.socketio_send("get-info",data)



#dev tools
func _on_dev_screen_add_components():
	if stats.dev_mode:
		client.socketio_send("add-components",{})
	else:
		pass

func _on_dev_screen_add_templates():
	if stats.dev_mode:
		client.socketio_send("add-templates",{})
	else:
		pass

func _on_dev_screen_auto_login(data):
	if stats.dev_mode:
		client.socketio_send("login", data)
	else:
		pass

func _on_dev_screen_get_glossary() -> void:
	client.socketio_send("get-glossary")

func _on_card_editor_back_to_menu() -> void:
	change_scene("menu")

func _on_main_menu_start_rewards_screen() -> void:
	rewards_screen.reset()
	change_scene("rewards")

func _on_rewards_screen_close_rewards() -> void:
	change_scene("menu")

func _on_main_menu_start_card_editor() -> void:
	#change_scene("card_editor")
	client.socketio_send("card-view-all",{
		"on_success":"start-card-editor",
		"query":{
			#"subtype":"unit",
			#"image_status":"none",
			#"name_status":"none"
			"image_or_name_status":"none",
			#"unique_key":""
			}
		})
	#client.socketio_send("card-view-missing-name")

func _on_card_editor_imagegen_get_unit_classes_and_races(_card_id: Variant) -> void:
	client.socketio_send("get-info",{"id":_card_id,"type":"card","on_success":"get_info_card_image_edit"})
	client.socketio_send("imagegen-get-unit-requirements",{"card_id" : _card_id})

func _on_card_editor_imagegen_get_unit_options(_data: Variant) -> void:
	client.socketio_send("imagegen-get-unit-options",_data)

func _on_card_editor_imagegen_make_unit_image(_data: Variant) -> void:
	client.socketio_send("imagegen-make-unit-image",_data)

func _on_card_editor_start_card_name_edit(_card_id: Variant) -> void:
	client.socketio_send("get-info",{"id":_card_id,"type":"card","on_success":"get_info_card_name_edit"})

func _on_card_editor_validate_card_name(_data: Variant) -> void:
	client.socketio_send("validate-card-name",_data)

func _on_card_editor_save_card_name(_data: Variant) -> void:
	client.socketio_send("save-card-name",_data)

func _on_dev_screen_get_reward():
	client.socketio_send("rewards-get-containers")

func _on_dev_screen_open_common_reward() -> void:
	client.socketio_send("rewards-open-containers",{"container" : 1, "quantity" : 1})

func _on_dev_screen_open_uncommon_reward() -> void:
	client.socketio_send("rewards-open-containers",{"container" : 3, "quantity" : 1})

func _on_deck_editor_avatar_selected(_card_id: Variant) -> void:
	client.socketio_send("get-info",{"id":_card_id,"type":"card","on_success":"get_info_deck_editor_card_avatar_selected"})

func _on_dev_screen_edit_card(_id: Variant) -> void:
	client.socketio_send("get-info",{"id":_id,"type":"card","on_success":"get_info_card_image_edit"})
	client.socketio_send("imagegen-get-unit-requirements",{"card_id" : _id})

func _on_rewards_screen_selected_reward(_id: Variant, _amount: Variant) -> void:
	print(_id,_amount)
	client.socketio_send("rewards-open-containers",{"container":_id, "quantity":_amount})


func _on_hud_back() -> void:
	match current_scene:
		"wrong_version":
			pass
		"login":
			pass
		"register":
			pass
		"menu":
			pass
		"deck_select":
			client.socketio_send("cancel-select-deck")
		"waiting":
			if waiting_for_game_screen.cancel_status == "cancel-waiting-for-validation":
				client.socketio_send("cancel-waiting-for-validation")
				#cancel_validation.emit()
			elif waiting_for_game_screen.cancel_status == "cancel-waiting-for-game":
				client.socketio_send("cancel-waiting-for-game")
				#cancel_game.emit()
			else:
				return
		"card_select":
			pass
		"game_select":
			change_scene("menu")
		"game":
			pass
		"game_finished":
			change_scene("menu")
		"card_view":
			change_scene("menu")
		"card_builder":
			client.socketio_send("close-card-builder")
		"card_editor":
			change_scene("menu")
		"deck_editor":
			client.socketio_send("close-deck-editor")
		"rewards":
			change_scene("menu")
		_:
			print("No Scene")
