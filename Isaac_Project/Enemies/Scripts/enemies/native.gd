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
		fire_spear()
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
	if not player:
		return
	
	# Prevent continuous firing
	can_attack = false
	is_attacking = true
	
	# Stop moving while firing
	velocity = Vector2.ZERO
	
	var spear = spear_scene.instantiate()
	get_parent().add_child(spear)
	
	spear.global_position = global_position
	
	var direction = (player.global_position - global_position).normalized()
	spear.launch(direction)
	
	# Start cooldown
	attack_timer.start()
	
	# Reset attacking state after a brief delay (or when animation finishes)
	await get_tree().create_timer(0.3).timeout
	is_attacking = false
	
	#TODO: play throw sound and animation

func _on_attack_timer_timeout() -> void:
	# Start cooldown
	attack_timer.start()
	is_attacking = false
	
	# Reset state
	can_attack = true
	is_attacking = false
	anim_sprite.play("idle")

# -------------------
# NATIVE ENEMY DEATH
# -------------------
func _on_died() -> void:
	queue_free()
