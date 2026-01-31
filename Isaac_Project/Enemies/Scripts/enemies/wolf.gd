extends EnemyBase
class_name Wolf

@export var damage: int

func _ready() -> void:
	super._ready() # Initialize all attributes in EnemyBase
	# Ensure attack timer is setup
	attack_timer.wait_time = data.attack_speed
	
	anim_sprite.animation_finished.connect(_on_animation_finished)

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
	# Reset state
	can_attack = true
	is_attacking = false
	anim_sprite.play("idle")

func _on_animation_finished() -> void:
	if anim_sprite.animation == "attack":
		# Deal damage at end of attack animation
		if player and player.has_node("Health"):
			var distance = global_position.distance_to(player.global_position)
			if distance <= attack_range:
				var player_health: Health = player.get_node("Health")
				player_health.take_damage(damage)
				print("Player Health: " + str(player_health.current_health))
		
		# Start cooldown
		attack_timer.start()
		is_attacking = false

func _on_died() -> void:
	queue_free()
