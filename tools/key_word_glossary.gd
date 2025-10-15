extends Node

var key_glossary = {}
var glossary = {}

var neverknow_approved_items = [
	"Armor +1","Attack +1","Cleave +1"
	,"Counterattack +1","Efficient +1"
	,"Fortify +1","Healer +1","Health +1"
	,"Impale +1","Melee +2","Ranged +1",
]

func set_glossary(payload):
	#print(payload)
	if payload.has("glossary"):
		key_glossary = {}
		glossary = {}
		for item in payload["glossary"]:
			glossary[item["name"]] = {
				"key" : item["key"],
				"name" : item["name"],
				"description" : item["description"],
				"dependencies" : item["dependencies"]
			}
			key_glossary[item["key"]] = {
				"key" : item["key"],
				"name" : item["name"],
				"description" : item["description"],
				"dependencies" : item["dependencies"]
			}
	#print(glossary)
