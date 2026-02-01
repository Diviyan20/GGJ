extends CharacterBody2D
class_name EnemyBase

# === DATA RESOURCE ===
# Injected from data resource (EnemyData)
@export var data: EnemyData

# === RUNTIME STATE ===
var current_health: float
var can_attack: bool
var is_attacking: bool = false
var player: CharacterBody2D

# === CHASE SETTINGS ===
@export var chase_enabled: bool = true
@export var attack_range: float = 16.0

# ==== SEPARATION SETTINGS ===
@export var separation_enabled: bool = true
@export var separation_radius: float = 32.0  # Distance to maintain from other enemies
@export var separation_strength: float = 0.5  # How strongly to avoid (0-1)

# === NODES ===
@onready var anim_sprite: AnimatedSprite2D = $SuperSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var health: Health = $Health


func _ready() -> void:
	add_to_group("enemies")
	# Initialize stats from data resource
	if data == null:
		push_warning("Enemy has no EnemyData assigned!")
		return
	#current_health = data.health
	can_attack = true
	
	if player == null:
		player = get_tree().current_scene.get_node("Player")
	
	if player:
		print("EnemyBase: Player Assigned")
	else:
		push_error("EnemyBase: Could not find the Player node in the scene!")
	
	# Configure Attack Timer
	attack_timer.wait_time = data.attack_speed
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	
	health.died.connect(_on_died)

# -------------------
# DAMAGE SYSTEM
# -------------------



func drop_coins() -> void:
	# Spawn the coins when enemies are dead
	# Call from GameManager for simplicity
	#GameManager.add_coins(data.coins_amount)
	pass

# ------------------------
# CHASE SYSTEM
# ------------------------
func chase_player(_delta: float) -> void:
	if not chase_enabled or player == null:
		return
	
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	
	# Stop if too close (Prevents jitter and stacking)
	if distance <= attack_range:
		velocity = Vector2.ZERO
	else:
		# Calculate chase direction
		var chase_direction = to_player.normalized()
		
		# Apply separation from other enemies
		var separation = calculate_separation()
		
		# Blend chase and separation
		var final_direction = chase_direction + (separation * separation_strength)
		final_direction = final_direction.normalized()
		
		velocity = final_direction * data.speed
	move_and_slide()

func calculate_separation() -> Vector2:
	if not separation_enabled:
		return Vector2.ZERO
	
	var separation_vector := Vector2.ZERO
	var nearby_count := 0
	
	# Check all enemies in the group
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == self:
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		
		# If enemy is too close, push away
		if distance < separation_radius and distance > 0:
			var push_direction = (global_position - enemy.global_position).normalized()
			var push_force = 1.0 - (distance / separation_radius)  # Stronger when closer
			separation_vector += push_direction * push_force
			nearby_count += 1
	
	# Average the separation force
	if nearby_count > 0:
		separation_vector = separation_vector.normalized()
	
	return separation_vector

# ------------------
# HELPERS (SPRITE FLIPPING)
# ------------------
func update_facing() -> void:
	if player == null:
		return
	anim_sprite.flip_h = player.global_position.x > global_position.x

# ----------------
# ATTACK SYSTEM
# ----------------
func start_attack() -> void:
	if is_attacking or not can_attack:
		return
	is_attacking = true
	can_attack = false
	
	# Stop moving while attacking
	velocity = Vector2.ZERO
	
	# Play attack animation
	anim_sprite.play("attack")
	
	# TODO: apply damage to player here
	# player.take_damage(data.damage)
	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	can_attack = true

# ----------------------------
# SIGNAL FOR DAMAGE SYSTEM
# ----------------------------
func _on_died() -> void:
	queue_free()
