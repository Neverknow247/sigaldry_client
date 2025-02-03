extends Control

var scene_name = "card_select"

func add_cards(payload):
	#print(payload)
	for card in payload["select_from"]:
		print(card)
