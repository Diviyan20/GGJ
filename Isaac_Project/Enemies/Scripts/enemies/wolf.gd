extends EnemyBase
class_name Wolf

@export var attack_range: float  = 50.0 # Distance to trigger melee attack
@export var damage: int =2

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
			anim_sprite.play("walk")
		else:
			anim_sprite.play("idle")

# -----------------
# TIMER CALLBACK
# -----------------
func _on_attack_timer_timeout() -> void:
	# Deal damage if player is still in range
	if player != null and global_position.distance_to(player.global_position) <= attack_range:
		# TODO: call function for player to take damage
		#player.take_damage(damage)
		pass
	
	# Reset state
	can_attack = true
	is_attacking = false
	anim_sprite.play("idle")
