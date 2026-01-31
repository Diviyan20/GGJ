extends CharacterBody2D
class_name EnemyBase

# === DATA RESOURCE ===
# Injected from data resource (EnemyData)
@export var data: EnemyData

# === RUNTIME STATE ===
var current_health: float
var can_attack: bool
var player: CharacterBody2D

# === CHASE SETTINGS ===
@export var chase_enabled: bool = true
@export var stop_distance: float = 16.0

# === NODES ===
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer


func _ready() -> void:
	# Initialize stats from data resource
	if data == null:
		push_warning("Enemy has no EnemyData assigned!")
		return
	current_health = data.health
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

func _physics_process(delta: float) -> void:
	if player == null:
		return
	chase_player(delta)

# -------------------
# DAMAGE SYSTEM
# -------------------

func take_damage(base_damage: int, masked_multiplier: int) -> void:
	# Final damage depends on masked matchup
	var final_damage = int(base_damage * masked_multiplier)
	current_health -= final_damage
	
	# Optional: Play hit flash or sound here
	
	if current_health <= 0:
		die()

# ---------------
# ENEMY DEATH
# ---------------

func die() -> void:
	drop_coins()
	queue_free()

func drop_coins() -> void:
	# Spawn the coins when enemies are dead
	# Call from GameManager for simplicity
	#GameManager.add_coins(data.coins_amount)
	pass

# ------------------------
# CHASE SYSTEM
# ------------------------
func chase_player(delta: float) -> void:
	if not chase_enabled or player == null:
		return
	
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	
	# Stop if too close (Prevents jitter and stacking)
	if distance <= stop_distance:
		velocity = Vector2.ZERO
	else:
		var direction = to_player.normalized()
		velocity = direction * data.speed
	
	move_and_slide()

# ----------------
# ATTACK SYSTEM
# ----------------
func try_attack() -> void:
	# Called when enemy is in range
	if not can_attack:
		return
	can_attack = false
	
	# TODO: apply damage to player here
	# player.take_damage(data.damage)
	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	can_attack = true
