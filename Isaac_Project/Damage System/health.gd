extends Node
class_name Health

signal damaged(amount: float)
signal healed(amount: float)
signal died

@export var max_health: float = 10.0

var current_health: float

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	if amount <= 0:
		return
	if is_dead():
		return

	current_health -= amount
	current_health = max(current_health, 0)
	
	damaged.emit(amount)
	
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
