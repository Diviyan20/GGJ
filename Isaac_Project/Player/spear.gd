extends Area2D

@export var speed := 600
@export var damage := 15
var direction := Vector2.ZERO

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.has_node("Health"):
		var target_health: Health = body.get_node("Health")
		target_health.take_damage(damage)
		print("Enemy Health: " + str(target_health.current_health))
	else:
		print("No Health node found on ", body.name)
	queue_free()
