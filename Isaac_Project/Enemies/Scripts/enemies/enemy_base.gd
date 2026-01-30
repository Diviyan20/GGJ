extends CharacterBody2D

class_name EnemyBase

# === DATA RESOURCE ===
# Injected from data resource (EnemyData)
@export var data: EnemyData

# === RUNTIME STATE ===
var current_health: float
var can_attack: bool
var player: CharacterBody2D = null

# === NODES ===
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_timer: Timer = $AttackTimer


func _ready() -> void:
	# Initialize stats from data resource
	if data == null:
		push_warning("Enemy has no EnemyData assigned!")
		return
	current_health = data.health
	
	# Cache player reference
	player = get_tree().get_first_node_in_group("player")
	
	# Configure Attack Timer
	attack_timer.wait_time = data.attack_speed
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(_delta: float) -> void:
	# Default behavior:
	# Move directly toward player
	
	# Child enemies can override this function to create dash, ranged
	# and snake logic
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * data.speed
	move_and_slide()

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
