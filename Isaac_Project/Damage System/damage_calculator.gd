extends Node
class_name DamageCalculator

# Damage multiplier table
# [Attacker][Defender] = multiplier
static var MULTIPLIERS := {
	"Native": {
		"Wolf": 1.5,      # Native beats Wolf
		"Snake": 0.2,     # Snake beats Native
		"Native": 1.0,
		"Godot": 1.0,
		"default": 1.0
	},
	"Wolf": {
		"Snake": 2.0,     # Wolf beats Snake
		"Native": 0.5,    # Native beats Wolf (reverse)
		"Wolf": 1.0,
		"Godot": 1.0,
		"default": 1.0
	},
	"Snake": {
		"Native": 1.5,    # Snake beats Native (enemy attacking)
		"Wolf": 0.5,      # Wolf beats Snake (reverse)
		"Snake": 1.0,
		"Godot": 1.0,
		"default": 1.0
	},
	"Godot": {
		"Native": 3.0,
		"Wolf": 3.0,
		"Snake": 3.0,
		"Godot": 1.0,
		"default": 3.0
	},
	"default": {
		"default": 1.0
	}
}

static func calculate_damage(base_damage: float, attacker_type: String, defender_type: String) -> float:
	var multiplier = get_multiplier(attacker_type, defender_type)
	return base_damage * multiplier

static func get_multiplier(attacker_type: String, defender_type: String) -> float:
	if not MULTIPLIERS.has(attacker_type):
		return 1.0
	
	var attacker_table = MULTIPLIERS[attacker_type]
	
	if attacker_table.has(defender_type):
		return attacker_table[defender_type]
	
	return attacker_table.get("default", 1.0)
