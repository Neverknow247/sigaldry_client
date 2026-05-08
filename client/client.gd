class_name DeckmasterClient extends Node

var stats = Stats
var utils = Utils
#var KEYWORD_GLOSSARY = KeyWordGlossary

var client = SocketIOClient
var backendURL: String
var default_backendURL = "http://3.139.99.80/socket.io"

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

@onready var disconnect_screen: Control = $scenes/disconnect_screen
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
@onready var editor_select_screen: Control = $scenes/editor_select_screen
@onready var card_editor: Control = $scenes/card_editor
@onready var deck_editor: Control = $scenes/deck_editor
@onready var rewards_screen: Control = $scenes/rewards_screen
@onready var card_edit_screen: Control = $scenes/card_edit_screen
@onready var card_image_edit: Control = $scenes/card_image_edit
@onready var card_name_edit: Control = $scenes/card_name_edit
@onready var fusion_screen: Control = $scenes/fusion_screen
@onready var salvage_screen: Control = $scenes/salvage_screen
@onready var store_screen: Control = $scenes/store_screen

var current_scene = ""
var new_card = true

func _ready():
	# prepare URL
	
	#backendURL = "http://localhost:3000/socket.io"
	#backendURL = "http://127.0.0.1:3000/socket.io"
	 #97.179.250.141
	#aws
	backendURL = "http://3.139.99.80/socket.io"
	#ethernet
	#backendURL = "http://192.168.1.151:3000/socket.io"
	#wifi
	#backendURL = "http://172.28.48.1:3000/socket.io"
	initialize_client()

func initialize_client():
	# initialize client
	client = SocketIOClient.new(backendURL, {"token": "MY_AUTH_TOKEN"})

	# this signal is emitted when the socket is ready to connect
	client.on_engine_connected.connect(on_socket_ready)

	# this signal is emitted when socketio server is connected
	client.on_connect.connect(on_socket_connect)

	# this signal is emitted when socketio server sends a message
	client.on_event.connect(on_socket_event)

	client.on_connection_lost.connect(on_socket_disconnect)
	
	client.on_reconnected.connect(on_socket_reconnect)
	
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

func on_socket_disconnect():
	change_scene("disconnect_screen")

func on_socket_reconnect(_payload: Variant, _name_space, error: bool):
	if error:
		push_error("Failed to connect to backend! Error: ",error)
	else:
		print("Socket reconnected")
		change_scene("login")

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
		if payload.has("sequence"):
			print(payload["sequence"])
		else:
			#show_error("NO SEQUENCE")
			print("NO SEQUENCE", payload)
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
			#print(payload)
			if ProjectSettings.get_setting("application/config/version") != payload["server_version"]:
				change_scene("wrong_version")
				return
			stats.setup_player(payload)
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
			#change_scene("menu")
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
		"compare_card_select":
			card_builder.view_cards(payload)
		"start-card-editor":
			change_scene("card_editor")
			card_editor.add_cards(payload)
		"imagegen-get-unit-requirements":
			card_image_edit.set_unit_requirements(payload)
			change_scene("card_image_edit")
		"imagegen-get-unit-options":
			card_image_edit.set_unit_options(payload)
		"imagegen-unit-image-started":
			show_error({"message":"Image Started"})
			client.socketio_send("card-view-all",{
			#"on_success":"start-card-editor",
			"query":{
				#"subtype":"unit",
				#"image_status":"none",
				#"name_status":"none"
				#"image_or_name_status":"none",
				#"unique_key":""
				}
			})
		"imagegen-unit-image-complete":
			show_error({"message":"Image Complete"})
		"imagegen-unit-image-failed":
			show_error({"message":"Image Failed"})
		"imagegen-spell-image-started":
			show_error({"message":"Image Started"})
			client.socketio_send("card-view-all",{
			#"on_success":"start-card-editor",
			"query":{
				#"subtype":"unit",
				#"image_status":"none",
				#"name_status":"none"
				#"image_or_name_status":"none",
				#"unique_key":""
				}
			})
		"imagegen-spell-image-complete":
			show_error({"message":"Image Complete"})
		"imagegen-spell-image-failed":
			show_error({"message":"Image Failed"})
		"imagegen-get-spell-requirements":
			change_scene("card_image_edit")
			card_image_edit.set_spell_requirements(payload)
		"validate-card-name":
			show_error({"message":"Card Name Validated"})
			card_name_edit.card_name_validated(payload)
		"save-card-name":
			show_error({"message":"Card Name Saved"})
			client.socketio_send("card-view-all",{
			#"on_success":"start-card-editor",
			"query":{
				#"subtype":"unit",
				#"image_status":"none",
				#"name_status":"none"
				#"image_or_name_status":"none",
				#"unique_key":""
				}
			})
		"card-builder-save-complete":
			client.socketio_send("close-card-builder")
			if new_card:
				client.socketio_send("card-view-all",{
					"custom_responses":[
						{
							"before":"card-view-all",
							"after":"start-card-editor"
						}
					],
					#"on_success":"start-card-editor",
					"query":{
						#"subtype":"unit",
						#"image_status":"none",
						#"name_status":"none"
						"image_or_name_status":"none",
						#"unique_key":""
						}
					})
			else:
				#change_scene("menu")
				client.socketio_send("start-card-builder")
		"card-view-all":
			change_scene("card_view")
			card_view_screen.store_items(payload)
			fusion_screen.store_items(payload)
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
			pass
			#change_scene("menu")
		
		#game events
		"set_up_pve":
			change_scene("game_select")
			game_select_screen.set_up_pve(payload)
		"set_up_pvp":
			change_scene("game_select")
			game_select_screen.set_up_pvp(payload)
		#"new-game-options":
			#game_select_screen.set_up_pve(payload)
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
			print("**********************************")
			print("UPDATE TILES PAYLOAD: ",payload)
			for i in payload:
				print(i)
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
			card_image_edit.get_info_card_image_edit(payload)
		"get_info_card_name_edit":
			change_scene("card_name_edit")
			card_name_edit.get_info_card_name_edit(payload)
		"start-game":
			change_scene("game")
		"choose-target":
			#utils.j_print(payload)
			game_screen.choose_target(payload)
		"quit-game":
			hud.quit_game(payload)
			game_screen.quit_game(payload)
			change_scene("game_finished")
			game_finished_screen.quit_game(payload)
			#main_menu.quit_game(payload)
		"rewards-get-containers":
			hud.check_rewards(payload)
			rewards_screen.set_up_rewards(payload)
			#main_menu.check_rewards(payload)
			#print(JSON.stringify(payload, "\t"))
		"rewards-open-containers":
			rewards_screen.show_rewards(payload)
			client.socketio_send("rewards-get-containers")
			#print(JSON.stringify(payload, "\t"))
		"rewards-earned-containers":
			pass
			#print(JSON.stringify(payload, "\t"))
		#"card-view-all":
			#print(payload)
		"start_card_edit_screen":
			card_edit_screen.get_info_card_edit(payload)
			salvage_screen.get_info_card_salvage(payload)
			change_scene("card_edit")
			fusion_screen.set_fusion_card("card_1",payload)
		"get-card-image-files","get-card-image-keys","get-opponent-card-image-keys":
			if typeof(payload) == TYPE_DICTIONARY:
				card_art_cache.route_server_message({"type": event_name, "data": payload})
			else:
				card_art_cache.route_server_message({"type": event_name, "data": {}})
		"fusion-card-1":
			fusion_screen.set_fusion_card("card_1",payload)
		"fusion-card-2":
			fusion_screen.set_fusion_card("card_2",payload)
		"preview-fused-card":
			fusion_screen.set_fusion_card("fusion_card",payload)
		"fuse-cards":
			client.socketio_send("card-view-all",{
			#"on_success":"start-card-editor",
			"query":{
				#"subtype":"unit",
				#"image_status":"none",
				#"name_status":"none"
				#"image_or_name_status":"none",
				#"unique_key":""
				}
			})
		"store-get-categories":
			#utils.j_print(payload)
			store_screen.store_get_categories(payload)
			change_scene("store")
		"store-get-containers":
			store_screen.store_get_containers(payload)
		"store-purchase-containers":
			client.socketio_send("rewards-get-containers")
			store_screen.reset_containers()
			#utils.j_print(payload)
		"salvage-card-options":
			#utils.j_print(payload)
			salvage_screen.salvage_card_options(payload)
			change_scene("salvage_screen")
		"scrap-card":
			client.socketio_send("card-view-all",{
			#"on_success":"start-card-editor",
			"query":{
				#"subtype":"unit",
				#"image_status":"none",
				#"name_status":"none"
				#"image_or_name_status":"none",
				#"unique_key":""
				}
			})
		"duplicate-card":
			client.socketio_send("card-view-all",{
			#"on_success":"start-card-editor",
			"query":{
				#"subtype":"unit",
				#"image_status":"none",
				#"name_status":"none"
				#"image_or_name_status":"none",
				#"unique_key":""
				}
			})
		"salvage-card":
			client.socketio_send("card-view-all",{
			#"on_success":"start-card-editor",
			"query":{
				#"subtype":"unit",
				#"image_status":"none",
				#"name_status":"none"
				#"image_or_name_status":"none",
				#"unique_key":""
				}
			})
		_:
			print("Unknown Event: ", event_name)

func show_error(payload):
	#print(payload)
	if payload["message"]:
		#print("message here")
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
		"login","register","wrong_version","disconnect_screen":
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

func _on_card_view_screen_start_edit_card(_id: Variant) -> void:
	client.socketio_send("get-info",{"id":_id,"type":"card",
	"custom_responses":[
		{
			"before":"get-info",
			"after":"start_card_edit_screen"
		}
	],
	#"on_success":"start_card_edit_screen"
	})

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

func _on_card_builder_save_card() -> void:
	client.socketio_send("card-builder-save-card")

func _on_card_builder_set_new_card(_new_card: Variant) -> void:
	new_card = _new_card

func _on_card_builder_piece_rotate(direction: Variant) -> void:
	client.socketio_send("card-builder-rotate-component",direction)

func _on_card_builder_piece_flip() -> void:
	client.socketio_send("card-builder-flip-component",{"direction":"horizontal"})

func _on_card_builder_move_set(data):
	client.socketio_send("card-builder-add-component",data)

func _on_card_builder_undo():
	client.socketio_send("card-builder-unset-component",{})

func _on_card_builder_compare_card_select():
	#client.socketio_send("view-cards",{"unit_only":false,"builder":true})
	client.socketio_send("card-view-all",{
		"custom_responses":[
						{
							"before":"card-view-all",
							"after":"compare_card_select"
						}
					],
		#"on_success":"compare_card_select",
		"query":{
			#"subtype":"unit",
			#"image_status":"none",
			#"name_status":"none"
			#"image_or_name_status":"none",
			#"unique_key":""
			}
		})

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
		"custom_responses":[
						{
							"before":"card-view-all",
							"after":"deck-editor-start-new-deck"
						}
					],
		#"on_success" : "deck-editor-start-new-deck",
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
		"custom_responses":[
						{
							"before":"card-view-all",
							"after":"deck-editor-new-deck-units"
						}
					],
		#"on_success":"deck-editor-new-deck-units",
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
		"custom_responses":[
						{
							"before":"card-view-all",
							"after":"start-card-editor"
						}
					],
		#"on_success":"start-card-editor",
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
	client.socketio_send("get-info",{"id":_card_id,"type":"card",
	"custom_responses":[
						{
							"before":"get-info",
							"after":"get_info_card_image_edit"
						}
					],
	#"on_success":"get_info_card_image_edit"
	})
	client.socketio_send("imagegen-get-unit-requirements",{"card_id" : _card_id})

func _on_card_editor_imagegen_get_requirements(_card_id: Variant, card_subtype: Variant) -> void:
	client.socketio_send("get-info",{"id":_card_id,"type":"card",
	"custom_responses":[
						{
							"before":"get-info",
							"after":"get_info_card_image_edit"
						}
					],
	#"on_success":"get_info_card_image_edit"
	})
	match card_subtype:
		"avatar", "unit":
			client.socketio_send("imagegen-get-unit-requirements",{"card_id" : _card_id})
		"trap":
			return
		"spell":
			client.socketio_send("imagegen-get-spell-requirements",{"card_id" : _card_id})
		"potion":
			return
		_:
			return
		

func _on_card_editor_imagegen_get_unit_options(_data: Variant) -> void:
	client.socketio_send("imagegen-get-unit-options",_data)

func _on_card_editor_imagegen_make_image(_data: Variant, _card_subtype: Variant) -> void:
	print("Data: ", _data, " Subtype: ", _card_subtype)
	match _card_subtype:
		"avatar", "unit":
			#print("Attempting Unit")
			client.socketio_send("imagegen-make-unit-image",_data)
		"trap":
			return
		"spell":
			#print("Attempting Spell")
			client.socketio_send("imagegen-make-spell-image",_data)
		"potion":
			return
		_:
			return

func _on_card_editor_start_card_name_edit(_card_id: Variant) -> void:
	client.socketio_send("get-info",{"id":_card_id,"type":"card",
		"custom_responses":[
						{
							"before":"get-info",
							"after":"get_info_card_name_edit"
						}
					],
	#"on_success":"get_info_card_name_edit"
	})

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
	client.socketio_send("get-info",{"id":_card_id,"type":"card",
	"custom_responses":[
						{
							"before":"get-info",
							"after":"get_info_deck_editor_card_avatar_selected"
						}
					],
	#"on_success":"get_info_deck_editor_card_avatar_selected"
	})

func _on_dev_screen_edit_card(_id: Variant) -> void:
	client.socketio_send("get-info",{"id":_id,"type":"card",
	"custom_responses":[
						{
							"before":"get-info",
							"after":"get_info_card_image_edit"
						}
					],
	#"on_success":"get_info_card_image_edit"
	})
	client.socketio_send("imagegen-get-unit-requirements",{"card_id" : _id})
	#client.socketio_send("imagegen-get-spell-requirements",{"card_id" : _id})

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


func _on_hud_cancel() -> void:
	match current_scene:
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

func _on_hud_home() -> void:
	match current_scene:
		"card_builder":
			client.socketio_send("close-card-builder")
		"deck_editor":
			client.socketio_send("close-deck-editor")
	change_scene("menu")

func _on_hud_rewards() -> void:
	match current_scene:
		"card_builder":
			client.socketio_send("close-card-builder")
		"deck_editor":
			client.socketio_send("close-deck-editor")
	rewards_screen.reset()
	change_scene("rewards")

func _on_hud_collection() -> void:
	match current_scene:
		"card_builder":
			client.socketio_send("close-card-builder")
		"deck_editor":
			client.socketio_send("close-deck-editor")
	client.socketio_send("card-view-all",{
		"query":{
			#"subtype":"unit",
			#"image_status":"none",
			#"name_status":"none"
			#"image_or_name_status":"none",
			#"unique_key":""
			}
		})

func _on_hud_build() -> void:
	match current_scene:
		"card_builder":
			client.socketio_send("close-card-builder",{"custom_responses":[
				{
					"before":"close-card-builder",
					"after":"start-card-builder"
				}
			]})
			#client.socketio_send("close-card-builder",{"on_success ":"start-card-builder"})
		"deck_editor":
			client.socketio_send("close-deck-editor",{
				"custom_responses":[
						{
							"before":"close-deck-editor",
							"after":"start-card-builder"
						}
					],
				#"on_success":"start-card-builder"
				})
			client.socketio_send("start-card-builder") 
		_:
			client.socketio_send("start-card-builder")

func _on_hud_edit() -> void:
	match current_scene:
		"card_builder":
			client.socketio_send("close-card-builder")
		"deck_editor":
			client.socketio_send("close-deck-editor")
	client.socketio_send("start-deck-editor")
	
	return
	change_scene("editor_select")
	client.socketio_send("card-view-all",{
		"custom_responses":[
						{
							"before":"card-view-all",
							"after":"start-card-editor"
						}
					],
		#"on_success":"start-card-editor",
		"query":{
			#"subtype":"unit",
			#"image_status":"none",
			#"name_status":"none"
			"image_or_name_status":"none",
			#"unique_key":""
			}
		})

func _on_hud_battle() -> void:
	match current_scene:
		"card_builder":
			client.socketio_send("close-card-builder")
		"deck_editor":
			client.socketio_send("close-deck-editor")
	game_select_screen.reset()
	change_scene("game_select")

func _on_main_menu_new_game() -> void:
	game_select_screen.reset()
	change_scene("game_select")

func _on_editor_select_screen_card_editor() -> void:
	#change_scene("card_editor")
	client.socketio_send("card-view-all",{
		"custom_responses":[
						{
							"before":"card-view-all",
							"after":"start-card-editor"
						}
					],
		#"on_success":"start-card-editor",
		"query":{
			#"subtype":"unit",
			#"image_status":"none",
			#"name_status":"none"
			"image_or_name_status":"none",
			#"unique_key":""
			}
		})

func _on_editor_select_screen_card_fusion() -> void:
	pass # Replace with function body.

func _on_editor_select_screen_deck_editor() -> void:
	client.socketio_send("start-deck-editor")

func _on_game_select_screen_pve_game_options() -> void:
	client.socketio_send("new-game-options",{
		"custom_responses":[
						{
							"before":"new-game-options",
							"after":"set_up_pve"
						}
					],
		#"on_success":"set_up_pve"
		})

func _on_game_select_screen_pvp_game_options() -> void:
	client.socketio_send("new-game-options",{
		"custom_responses":[
						{
							"before":"new-game-options",
							"after":"set_up_pvp"
						}
					],
		#"on_success":"set_up_pvp"
		})

func _on_game_select_screen_look_for_game(_data: Variant) -> void:
	client.socketio_send("start-looking-for-game",_data)

func _on_hud_user_change_account() -> void:
	client.socketio_send("user-change-account",{
		"client_settings" : {
			"pve_xp" : stats["pve_xp"],
			"pvp_xp" : stats["pvp_xp"],
		}
	})

func _on_main_menu_button_1() -> void:
	change_scene("editor_select")

func _on_main_menu_button_2() -> void:
	game_select_screen.reset()
	change_scene("game_select")

func _on_main_menu_button_3() -> void:
	pass # Replace with function body.


func _on_login_screen_change_ip(_new_ip: Variant) -> void:
	if _new_ip == "":
		backendURL = default_backendURL
	else:
		#"http://3.139.99.80/socket.io"
		backendURL = "http://"+_new_ip+"/socket.io"
	initialize_client()


func _on_card_edit_screen_start_fusion_edit(_card_id: Variant) -> void:
	change_scene("card_fusion")

func _on_card_edit_screen_start_image_edit(_card_id: Variant, _card_subtype: Variant) -> void:
	match _card_subtype:
		"avatar", "unit":
			client.socketio_send("imagegen-get-unit-requirements",{"card_id" : _card_id})
		"trap":
			return
		"spell":
			client.socketio_send("imagegen-get-spell-requirements",{"card_id" : _card_id})
		"potion":
			return
		_:
			return
	client.socketio_send("get-info",{"id":_card_id,"type":"card","custom_responses":[
		{
		"before":"get-info",
			"after":"get_info_card_image_edit"
		}],
	#"on_success":"get_info_card_image_edit"
	})

func _on_card_edit_screen_start_name_edit(_card_id: Variant) -> void:
	client.socketio_send("get-info",{"id":_card_id,"type":"card",
	"custom_responses":[
						{
							"before":"get-info",
							"after":"get_info_card_name_edit"
						}
					],
	#"on_success":"get_info_card_name_edit"
	})


func _on_card_image_edit_imagegen_get_unit_options(_data: Variant) -> void:
	client.socketio_send("imagegen-get-unit-options",_data)

func _on_card_image_edit_imagegen_make_image(_data: Variant, _card_subtype: Variant) -> void:
	print("Data: ", _data, " Subtype: ", _card_subtype)
	match _card_subtype:
		"avatar", "unit":
			#print("Attempting Unit")
			client.socketio_send("imagegen-make-unit-image",_data)
		"trap":
			return
		"spell":
			#print("Attempting Spell")
			client.socketio_send("imagegen-make-spell-image",_data)
		"potion":
			return
		_:
			return

func _on_card_name_edit_validate_card_name(_data: Variant) -> void:
	client.socketio_send("validate-card-name",_data)

func _on_card_name_edit_save_card_name(_data: Variant) -> void:
	client.socketio_send("save-card-name",_data)

func _on_hud_pve_battle() -> void:
	match current_scene:
		"card_builder":
			client.socketio_send("close-card-builder")
		"deck_editor":
			client.socketio_send("close-deck-editor")
	client.socketio_send("new-game-options",{
		"custom_responses":[
						{
							"before":"new-game-options",
							"after":"set_up_pve"
						}
					],
		#"on_success":"set_up_pve"
		})

func _on_hud_pvp_battle() -> void:
	match current_scene:
		"card_builder":
			client.socketio_send("close-card-builder")
		"deck_editor":
			client.socketio_send("close-deck-editor")
	client.socketio_send("new-game-options",{
		"custom_responses":[
						{
							"before":"new-game-options",
							"after":"set_up_pvp"
						}
					],
		#"on_success":"set_up_pvp"
		})

func _on_fusion_screen_preview_fused_card(_card_id_1: Variant, _card_id_2: Variant) -> void:
	client.socketio_send("preview-fused-card",{"card_id1":_card_id_1,"card_id2":_card_id_2})

func _on_fusion_screen_select_fusion_card(_card_num: Variant, _id: Variant) -> void:
	match _card_num:
		"card_1":
			client.socketio_send("get-info",{"id":_id,"type":"card",
			"custom_responses":[
						{
							"before":"get-info",
							"after":"fusion-card-1"
						}
					],
			#"on_success":"fusion-card-1"
			})
		"card_2":
			client.socketio_send("get-info",{"id":_id,"type":"card",
			"custom_responses":[
						{
							"before":"get-info",
							"after":"fusion-card-2"
						}
					],
			#"on_success":"fusion-card-2"
			})

func _on_fusion_screen_fuse_cards(_card_id_1: Variant, _card_id_2: Variant) -> void:
	client.socketio_send("fuse-cards",{"card_id1":_card_id_1,"card_id2":_card_id_2})

func _on_hud_shop() -> void:
	client.socketio_send("store-get-categories")

func _on_card_edit_screen_duplicate_card(_card_id: Variant) -> void:
	client.socketio_send("duplicate-card",{"card_id":_card_id})

func _on_card_edit_screen_salvage_card(_card_id: Variant) -> void:
	client.socketio_send("salvage-card-options",{"card_id":_card_id})

func _on_card_edit_screen_scrap_card(_card_id: Variant) -> void:
	client.socketio_send("scrap-card",{"card_id":_card_id})

func _on_store_screen_buy_item(_item_key: Variant, _item_quantity: Variant) -> void:
	client.socketio_send("store-purchase-containers",{"container":_item_key,"quantity":_item_quantity})

func _on_store_screen_category_selected(_category_id: Variant) -> void:
	client.socketio_send("store-get-containers",{"category_id":_category_id})

func _on_salvage_screen_salvage(_card_id: Variant, _components: Variant, _templates: Variant) -> void:
	#print("Components: ", _components)
	#print("Templates: ",_templates)
	client.socketio_send("salvage-card",{
		"card_id":_card_id,
		"components":_components,
		"templates":_templates
		})
