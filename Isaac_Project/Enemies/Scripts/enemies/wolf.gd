extends EnemyBase
class_name Wolf

@export var attack_range: float  = 24.0 # Distance to trigger melee attack
@export var damage: int =2

# Internal References
var is_attacking: bool = false

func _ready() -> void:
	super._ready() # Initialize all attributes in EnemyBase
	# Start idle animation
	anim_sprite.play("idle")
	
	# Ensure attack timer is setup
	attack_timer.wait_time = data.attack_speed
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	update_facing()

	if distance <= attack_range:
		start_attack()
	else:
		# Move toward player using EnemyBase chase system
		chase_player(delta)

		# Play walking animation if moving
		if velocity.length() > 0:
			play_anim("walk")
		else:
			play_anim("idle")
		
# -----------------
# ATTACK LOGIC
# -----------------
func start_attack() -> void:
	if is_attacking or not can_attack:
		return
	
	is_attacking = true
	can_attack = false
	
	# Stop moving while attacking
	velocity = Vector2.ZERO
	
	# Play attack animation
	anim_sprite.play("attack")
	
	# Schedule actual damage application when animation ends or after a short delay
	# For simplicity, we’ll just use a timer equal to attack_speed
	attack_timer.start()


# ------------------
# HELPERS (ANIMATION AND SPRITE FLIPPING)
# ------------------
func play_anim(name: String) -> void:
	if anim_sprite.animation != name:
		anim_sprite.play(name)

func update_facing() -> void:
	if player == null:
		return
	
	anim_sprite.flip_h = player.global_position.x < global_position.x

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
