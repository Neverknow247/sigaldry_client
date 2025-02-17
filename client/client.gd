class_name DeckmasterClient extends Node

var KEYWORD_GLOSS = KeywordGloss.new()

var client = SocketIOClient
var backendURL: String

@onready var all_scenes = $scenes.get_children()

@onready var login_screen = $scenes/login_screen
@onready var register_screen = $scenes/register_screen
@onready var main_menu = $scenes/main_menu
@onready var deck_select_screen = $scenes/deck_select_screen
@onready var waiting_for_game_screen = $scenes/waiting_for_game_screen
@onready var card_select_screen = $scenes/card_select_screen
@onready var game_screen = $scenes/game_screen
@onready var card_view_screen = $scenes/card_view_screen
@onready var card_builder = $scenes/card_builder
@onready var deck_editor = $scenes/deck_editor

func _ready():
	# prepare URL
	backendURL = "http://localhost:3000/socket.io"

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
	if payload:
		print(payload["sequence"])
	# hide login_screen and show basic menu
	match event_name:
		"exception":
			#show_error(payload)
			print(payload)
		"login":
			change_scene("menu")
		"logout":
			change_scene("login")
		"show-lobby":
			change_scene("menu")
		"builder-update-templates":
			card_builder.load_build_templates(payload)
		"start-card-builder":
			change_scene("card_builder")
			card_builder.reset_card_builder()
		"close-card-builder":
			change_scene("menu")
		"builder-update-components":
			card_builder.load_builder_components(payload)
			#load_builder_components(payload)
		"builder-update-grid":
			card_builder.load_builder_grid(payload)
		"editor-view-cards":
			change_scene("card_view")
			card_view_screen.add_cards(payload)
		"editor-update-cards-in-deck":
			deck_editor.update_cards_in_deck(payload)
		"editor-update-cards-not-in-deck":
			deck_editor.update_cards_not_in_deck(payload)
		"start-deck-editor":
			deck_editor.start_deck_editor(payload)
		"editor-update-decks":
			change_scene("deck_editor")
			deck_editor.update_decks(payload)
		"close-deck-editor":
			change_scene("menu")
		
		
		#game events
		"select-deck":
			change_scene("deck_select")
			card_select_screen.reset()
			deck_select_screen.add_decks(payload)
		"waiting":
			change_scene("waiting")
			waiting_for_game_screen.waiting(payload)
		"update-unit":
			game_screen.update_unit(payload)
			#print(payload)
			#pass
		"select-cards":
			change_scene("card_select")
			card_select_screen.update_cards(payload)
		"select-cards-timer-update":
			card_select_screen.countdown(payload)
		"update-selected-cards":
			card_select_screen.update_cards(payload)
		"update-turn":
			change_scene("game")
			game_screen.update_turn(payload)
			pass
		"add-combat-log":
			game_screen.add_combat_log(payload)
		"update-energy":
			game_screen.update_energy(payload)
		"update-victory-points":
			game_screen.update_victory_points(payload)
			#print(payload)
			pass
		"join-game":
			game_screen.join_game(payload)
			pass
		"update-players":
			game_screen.update_players(payload)
			pass
		"update-tile":
			game_screen.update_tile(payload)
			pass
		"start-game":
			#print(payload)
			pass
		"quit-game":
			game_screen.quit_game(payload)
			pass

func show_error(payload):
	if payload["message"]:
		$error_label.text = payload["message"]
		await get_tree().create_timer(4).timeout
		$error_label.text = ""

func change_scene(new_scene_name = ""):
	for scene in all_scenes:
		if scene.scene_name:
			if scene.scene_name == new_scene_name:
				scene.show()
			else:
				scene.hide()

func _on_login_screen_change_screen_to_register():
	change_scene("register")

func _on_register_screen_change_screen_to_login():
	change_scene("login")

func _on_card_view_screen_exit_menu():
	change_scene("menu")

func _on_login_screen_auto_login():
	client.socketio_send("login", {'username':"nk247",'password':"pass123"})

func _on_main_menu_logout():
	client.socketio_send("logout")




#func load_build_templates(payload):
	#$card_builder/template_select_code.clear()
	#$card_builder/template_select_code.add_item("Pick A Template", -1)
	#$card_builder/template_select_code.add_separator()
	#for item in payload["templates"]:
		#$card_builder/template_select_code.add_item(item["name"],item["id"])
		#if item["name"].contains("Legendary"):
			#$card_builder/template_select_code.add_separator()

#func load_builder_components(payload):
	#var component_container = $scenes/card_builder/component_container/VBoxContainer
	#var component_container_children = component_container.get_children()
	#for child in component_container_children:
		#child.queue_free()
	##print(payload)
	#if payload["components"]:
		#for component in payload["components"]:
			##if component["disabled"] or !KEYWORD_GLOSS.neverknow_approved_items.has(component["name"]):
				##continue
			#var component_button = preload("res://card_builder_scenes/component_button.tscn")
			#var new_component_button = component_button.instantiate()
			#new_component_button.get_node("Button").text = str(component["cost"])+"\n"+component["name"]
			#new_component_button.get_node("Button").tooltip_text = KEYWORD_GLOSS["glossary"][component["keywords"][0]["name"]]
			#new_component_button.component_id = component["id"]
			#new_component_button.connect("component_selected",on_component_selected)
			#component_container.add_child(new_component_button)
			#new_component_button.get_node("component_shape_grid").create_component_shapes(component)
			#print(component)

#func load_builder_grid(payload):
	#if payload:
		#$scenes/card_builder/card_grid.create_card_grid(payload["grid"],payload["card"]["components"])
		#card_builder.update_card_preview(payload["card"])
		#if payload["active_component"]:
			#$scenes/card_builder/card_grid.create_component_shapes(payload["active_component"])
			#$scenes/card_builder/card_grid/active_component.create_active_component(payload["active_component"])
		#else:
			#$scenes/card_builder/card_grid/active_component.create_active_component({'shape':[],'x':'0','y':'0','color':{'background_color':"FFFFFF"}})

#CARD BUILDER FUNCTIONS
func _on_card_builder_back_to_menu():
	client.socketio_send("close-card-builder")

func _on_card_builder_template_selected(id):
	client.socketio_send("builder-select-template",{'template_id':id})

func _on_card_builder_place_component():
	client.socketio_send("builder-set-component")

func _on_card_builder_set_component(id):
	client.socketio_send("builder-add-component",{'component_id':id})

func _on_card_builder_component_selected(id):
	client.socketio_send("builder-add-component",{'component_id':id})

func _on_card_builder_change_name(card_name):
	client.socketio_send("builder-change-name",{'name':card_name})

func _on_card_builder_save_card():
	client.socketio_send("builder-save-card")
	client.socketio_send("close-card-builder")

func _on_card_builder_move_card(cords):
	client.socketio_send("builder-move-component",cords)

func _on_card_builder_rotate_card(direction):
	client.socketio_send("builder-rotate-component",direction)

func _on_card_builder_move_set(data):
	client.socketio_send("builder-move-set",data)

func _on_card_builder_undo():
	client.socketio_send("builder-unset-component",{})

func _on_card_builder_restart():
	client.socketio_send("start-card-builder")

func _on_login_screen_login(username, password):
	client.socketio_send("login", {'username':username,'password':password})

func _on_register_screen_register(username, screen_name, password):
	client.socketio_send("register",{'username':username,'password':password,'screen_name':screen_name})

func _on_main_menu_search_for_pvp_game():
	client.socketio_send("start-looking-for-game")

func _on_main_menu_search_for_pve_game():
	client.socketio_send("play-pve")

func _on_main_menu_view_all_cards():
	client.socketio_send("view-cards",{})

func _on_main_menu_start_card_builder():
	client.socketio_send("start-card-builder")


#Deck Editor Functions
func _on_main_menu_start_deck_editor():
	client.socketio_send("start-deck-editor")

func _on_deck_editor_deck_selected(id):
	client.socketio_send("editor-select-deck",{"deck_id":id})

func _on_deck_editor_close_deck_editor():
	client.socketio_send("close-deck-editor")

func _on_deck_editor_add_card_to_deck(id):
	client.socketio_send("editor-add-card",{"card_id":id,"is_avatar":false})

func _on_deck_editor_add_avatar_to_deck(id):
	client.socketio_send("editor-add-card",{"card_id":id,"is_avatar":true})

func _on_deck_editor_remove_card_from_deck(id):
	client.socketio_send("editor-remove-card",{"card_id":id})

func _on_deck_editor_change_deck_name(deck_name):
	client.socketio_send("editor-change-name",{'name':deck_name})

func _on_deck_editor_delete_deck():
	client.socketio_send("editor-delete-deck",{})

func _on_deck_editor_create_new_deck(deck_name):
	client.socketio_send("editor-add-deck",{"name":deck_name})


#Game Functions
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
