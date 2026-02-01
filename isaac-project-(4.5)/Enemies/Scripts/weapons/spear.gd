extends Area2D
class_name Spear

@export var speed: float = 500.0
@export var damage: int = 1
@export var lifetime: float = 4.0

@onready var lifetime_timer = $LifetimeTimer

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	lifetime_timer.wait_time = lifetime
	lifetime_timer.start()
	
	lifetime_timer.timeout.connect(queue_free)
	
	body_entered.connect(_on_body_entered)


# -----------------
# LAUNCH SPEAR
# -----------------
func launch(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

# ------------------
# SPEAR MOVEMENT
# ------------------
func _physics_process(delta: float) -> void:
	position += direction * speed * delta

# -----------------------
# COLLISION DETECTION
# -----------------------
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		# TODO: hook into your player damage system
		# body.take_damage(damage)

		queue_free()
