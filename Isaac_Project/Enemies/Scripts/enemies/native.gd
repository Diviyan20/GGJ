extends  EnemyBase
class_name NativeEnemy

@export var spear_scene: PackedScene


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

# -------------------
# THROW SPEAR
# -------------------
func fire_spear() -> void:
	var spear = spear_scene.instantiate()
	get_parent().add_child(spear)
	
	spear.global_position = global_position
	
	var direction = (player.global_position - global_position).normalized()
	spear.launch(direction)
	
	#TODO: play throw sound and animation

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
