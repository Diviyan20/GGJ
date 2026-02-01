extends Node
class_name Health

signal damaged(amount: float)
signal healed(amount: float)
signal died

@export var max_health: float = 10.0
@export var entity_type: String = ""

var current_health: float

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float, attacker_type: String = "") -> void:
	if amount <= 0:
		return
	if is_dead():
		return
	
	# Calculate damage with multiplier
	var final_damage = amount
	if attacker_type != "" and entity_type != "":
		final_damage = DamageCalculator.calculate_damage(amount, attacker_type, entity_type)
		print("%s attacking %s: %.1f damage (%.1fx multiplier)" % [
			attacker_type, 
			entity_type, 
			final_damage,
			DamageCalculator.get_multiplier(attacker_type, entity_type)
		])
	
	current_health -= final_damage
	current_health = max(current_health, 0)
	
	damaged.emit(final_damage)
	
	if current_health <= 0:
		died.emit()
	
func heal(amount: float) -> void:
	if amount <= 0:
		return 
	if is_dead():
		return

	current_health += amount
	current_health = min(current_health, max_health)
	healed.emit(amount)

func is_dead() -> bool:
	return current_health <= 0
