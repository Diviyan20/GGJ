extends CharacterBody2D

@export var enemy_type := "Wolf" # Wolf / Snake / Native
@export var max_hp := 50
@export var move_speed := 80
@export var contact_damage := 10
@export var attacker: CharacterBody2D
var hp := max_hp
var is_dead := false


@export var target: Node2D

func _ready():
	hp = max_hp
	if target == null:
		target = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if is_dead or target == null:
		return

	var dir = (target.global_position - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()

func take_damage(amount: int, attacker_mask := ""):
	if is_dead:
		return

	if attacker_mask != "" and is_weak_against(attacker_mask):
		amount = int(amount * 1.5)

	hp -= amount
	$AnimationPlayer.play("hit")
	apply_knockback(attacker.global_position)

	if hp <= 0:
		die()

func is_weak_against(mask_name: String) -> bool:
	match enemy_type:
		"Wolf":
			return mask_name == "Native"
		"Snake":
			return mask_name == "Wolf"
		"Native":
			return mask_name == "Godot"
	return false

func die():
	is_dead = true
	velocity = Vector2.ZERO
	$CollisionShape2D.disabled = true
	$Hurtbox/CollisionShape2D.disabled = true
	$AnimationPlayer.play("die")
	await $AnimationPlayer.animation_finished
	queue_free()

func apply_knockback(from_pos: Vector2, strength := 200):
	var dir = (global_position - from_pos).normalized()
	velocity = dir * strength

func _on_Hitbox_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(contact_damage)
