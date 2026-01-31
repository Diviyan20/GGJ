extends  EnemyBase
class_name NativeEnemy

@export var preferred_distance: float = 160.0
@export var attack_range: float = 220.0
@export var windup_time: float = 0.4
@export var spear_scene: PackedScene

func _physics_process(delta: float) -> void:
	if player == null:
		return 
	
	var distance = global_position.distance_to(player.global_position)
	
	# Handle positioning logic
	handle_positioning(distance, delta)
	
	if distance <= attack_range:
		#start_attack()
		pass

# ----------------------
# POSITIONING
# ----------------------
func handle_positioning(distance: float, delta: float) -> void:
	if player == null:
		return
	var direction = (player.global_position - global_position).normalized()
	
	# Move towards player
	if distance > preferred_distance:
		velocity = direction * data.speed
	
	# Back away slightly
	elif distance < preferred_distance * 0.7:
		velocity = -direction * data.speed
	
	else:
		velocity = direction * data.speed * 0.2
	
	move_and_slide()

# -------------------
# ATTACK
# -------------------
func start_attack() -> void:
	if not can_attack or spear_scene == null:
		return
		
	can_attack = false
	#fire_spear()
	attack_timer.start()

func fire_spear() -> void:
	var spear = spear_scene.instantiate()
	get_parent().add_child(spear)
	
	spear.global_position = global_position
	
	var direction = (player.global_position - global_position).normalized()
	spear.launch(direction)
	
	#TODO: play throw sound and animation

func _on_attack_timer_timeout() -> void:
	can_attack = true
