extends Area2D
class_name EnemySpear

@export var speed:= 400.0
@export var lifetime:= 3.0

var direction:= Vector2.ZERO
var attacker_type: String = ""  # Set by player when spawning
var damage:= 10

@onready var sprite: Sprite2D = $Sprite2D
@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready() -> void:
	# Setup lifetime timer
	lifetime_timer.wait_time = lifetime
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	lifetime_timer.start()
	
	# Connect collision
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func launch(dir: Vector2, dmg: int = 10) -> void:
	direction = dir.normalized()
	damage = dmg
	
	# Rotate spear to point in direction of travel
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Check if it hit the player
	if body.is_in_group("player") or body.name == "Player":
		if body.has_node("Health"):
			var player_health: Health = body.get_node("Health")
			player_health.take_damage(damage, "Native")
			print("Player Health: " + str(player_health.current_health))
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Optionally destroy on hitting other areas (walls, shields, etc.)
	if area.is_in_group("obstacle"):
		queue_free()

func _on_lifetime_timeout() -> void:
	queue_free()
