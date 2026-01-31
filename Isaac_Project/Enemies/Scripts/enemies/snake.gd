extends EnemyBase
class_name Snake

@export var damage: int

func _ready() -> void:
	super._ready() # Initialize all attributes in EnemyBase
	# Ensure attack timer is setup
	attack_timer.wait_time = data.attack_speed

func _physics_process(delta: float) -> void:
	update_facing()
	if player == null:
		return
	var distance = global_position.distance_to(player.global_position)

	if distance <= attack_range and can_attack:
		start_attack()
	elif not is_attacking:
		chase_player(delta)

		if velocity.length() > 0:
			anim_sprite.play("slither")
		else:
			anim_sprite.play("idle")

# -----------------
# TIMER CALLBACK
# -----------------
func _on_attack_timer_timeout() -> void:
	# Check if the player has a health bar
	if player and player.has_node("Health"):
		var player_health: Health = player.get_node("Health")
		
		# Deal damage if player is still in range
		if global_position.distance_to(player.global_position) <= attack_range:
			player_health.take_damage(damage)
	
	# Reset state
	can_attack = true
	is_attacking = false
	anim_sprite.play("idle")
