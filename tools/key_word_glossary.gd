extends Node

class_name KeywordGloss

var glossary = {
		"cost": "Cost: the amount of energy that this card costs to play",
		"health": "Health: the amount of damage the unit can take before it dies",
		"attack": "Attack: the base damage the unit deals when targeting an enemy, or when targeted by an enemy",
		"actions": "Actions: the number of times the unit can be used in a single turn",
		"healer": "Healer: restores health on a target unit",
		"impale": "Impale: damage dealt to unit behind a target; cannot exceed the damage dealt to the target",
		"armor": "Armor: reduces attack and impale damage; depletes after each use",
		"poisonous": "Poisonous: applies poisoned to a target unit",
		"poisoned": "Poisoned: amount of damage suffered at the end of the turn; ignores armor and depletes after use",
		"lacerate": "Lacerate: applies bleeding to a target unit after a successful attack",
		"bleeding": "Bleeding: amount of damage suffered at the beginning of the turn; ignores armor and depletes after use",
		"recycle": "Recycle: return a card to the draw deck after it has been used; depletes after each use",
		"charming": "Charming: applies charmed to a target",
		"charmed": "Charmed: during the beginning of the turn, affected unit moves into a random unoccupied frontline space; negated by terrified and depletes after use",
		"terrifying": "Terrifying: applies terrified to a target",
		"terrified": "Terrified: during the beginning of the turn, affected unit moves into a random unoccupied backline space; negated by charmed and depletes after use",
		"counterattack": "Counterattack: adds to base damage when defending",
		"pacify": "Pacify: applies pacified to target",
		"pacified": "Pacified: affected unit cannot be used on enemy units; depletes at end of turn",
		"diseased": "Diseased: deals damage to affected unit and depletes at the beginning of every turn; spreads to all adjacent units at end of every turn",
		"apothecary": "Apothecary: removes poisoned and diseased from target, and applies immune",
		"immune": "Immune: prevents further application of poisoned or diseased, and prevents damage from diseased",
		"mark": "Mark: applies vulnerable to target; does not require a successful attack",
		"vulnerable": "Vulnerable: increases attack or counterattack damage dealt to affected unit; depletes at end of turn",
		"enfeeble": "Enfeeble: applies weak to target; does not require a successful attack",
		"weak": "Weak: reduces attack and counterattack damage dealt by this unit; depletes at end of turn",
		"cover": "Cover: extends backline targeting protection in each direction",
		"cleave": "Cleave: deals additional cleave damage to units on either side of target when attacking; cannot exceed attack value; affected by armor; does not trigger other abilities against adjacent units",
		"infuriate": "Infuriate: applies rage to target; does not require successful attack",
		"rage": "Rage: increases base damage of attack, impale, cleave and counterattack to and from affected unit",
		"fortify": "Fortify: add or restore armor to a target, up to the fortify value",
		"wither": "Wither: add or restore withering to a target, up to the wither value",
		"withering": "Withering: reduces max health by 1 at the end of the turn; depletes after use",
		"spawn": "Spawn: creates a new unit in an empty space at the end of the turn; prioritizes friendly empty spaces",
		"alleviate": "Alleviate: reduces all unfriendly statuses on a target",
		"weight": "Weight: cards is more likely to appear near the bottom of a shuffled deck",
		"enervate": "Enervate: applies enervated to a target",
		"enervated": "Enervated: affected unit does not recover actions during beginning of turn; depletes after use",
		"choices": "Choices: increases the number of options when asked to choose a card(s)",
		"faster": "Faster: reduces the length of each turn; negated by slower",
		"slower": "Slower: increases the length of each turn; negated by faster",
		"restock": "Restock: draw cards when the card is played",
		"conserve": "Conserve: persists unspent energy from one turn to the next",
		"melee": "Melee: increases base attack damage when targeting a unit in the same or adjacent row",
		"ranged": "Ranged: increases base attack damage when targeting a unit at least 1 row away; does not trigger a counterattack",
		"efficient": "Efficient: reduces the cost to play the card"
	}

var neverknow_approved_items = [
	"Armor +1","Attack +1","Cleave +1"
	,"Counterattack +1","Efficient +1"
	,"Fortify +1","Healer +1","Health +1"
	,"Impale +1","Melee +2","Ranged +1",
]
