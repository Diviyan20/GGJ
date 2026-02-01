extends CharacterBody2D

@export var starting_mask: MaskData
@export var spear_scene: PackedScene
@export var aoe_radius := 96
@export var move_speed := 100.0
@export var max_hp := 100
@export var starting_money := 0
var money := 0
var hp := max_hp
var can_attack := true
var current_mask: MaskData = null
var aim_dir: Vector2 = Vector2.DOWN
var owned_masks: Array[MaskData] = []
var base_move_speed := move_speed
var attack_speed_multiplier := 1.0

@onready var hud = get_tree().get_first_node_in_group("hud")

func _ready():
	money = starting_money
	update_money_ui()
	hp = max_hp
	if starting_mask:
		equip_mask(starting_mask)
	update_hp_bar()

func update_money_ui():
	if hud:
		hud.set_money(money)

func equip_mask(mask: MaskData):
	current_mask = mask
	if not owned_masks.has(mask):
		owned_masks.append(mask)
	print("Equipped mask:", mask.mask_name)

func _physics_process(delta):
	handle_movement()
	update_aim_direction()

func handle_movement():
	var input_dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if input_dir.length() > 0:
		input_dir = input_dir.normalized()

	velocity = input_dir * move_speed
	move_and_slide()

func get_move_speed() -> float:
	var speed := move_speed
	if current_mask:
		speed *= current_mask.speed_multiplier
	return speed * attack_speed_multiplier

func take_damage(amount: int):
	if current_mask and current_mask.has_shield:
		return
	hp -= amount
	hp = max(hp, 0)
	update_hp_bar()
	
	if hp <= 0:
		die()

func die():
	print("Player died")
	queue_free()

func heal(amount: int):
	hp = min(hp + amount, max_hp)
	update_hp_bar()

func update_hp_bar():
	var percent := float(hp) / float(max_hp) * 100.0
	$HPBarRoot/HPBar.value = percent


func update_aim_direction():
	var dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if dir.length() > 0:
		aim_dir = dir.normalized()

func _input(event):
	if event.is_action_pressed("Attack"):
		perform_attack()

func perform_attack():
	if not can_attack or current_mask == null:
		return

	can_attack = false

	match current_mask.mask_name:
		"Native":
			attack_native()
		"Wolf":
			attack_wolf()
		"Godot":
			attack_godot()

	await get_tree().create_timer(
	current_mask.attack_cooldown * attack_speed_multiplier
).timeout
	can_attack = true

func attack_native():
	var spear = spear_scene.instantiate()
	get_parent().add_child(spear)
	spear.global_position = global_position
	spear.direction = aim_dir
	spear.damage = current_mask.attack_damage

func attack_wolf():
	$AttackArea.global_position = global_position + aim_dir * 32
	$AttackArea.rotation = aim_dir.angle()

	for body in $AttackArea.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(current_mask.attack_damage, current_mask.mask_name)

func attack_godot():
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = aoe_radius

	query.shape = shape
	query.transform = Transform2D(0, global_position)

	var results = space_state.intersect_shape(query)

	for result in results:
		var body = result.collider
		if body.has_method("take_damage"):
			body.take_damage(current_mask.attack_damage, current_mask.mask_name)

func add_money(amount: int):
	money += amount
	update_money_ui()

func can_afford(amount: int) -> bool:
	return money >= amount

func spend_money(amount: int) -> bool:
	if money < amount:
		return false
	money -= amount
	update_money_ui()
	return true

func apply_potion(potion: PotionData):
	match potion.potion_name:
		"Heal Potion":
			heal(int(potion.value))

		"Speed Potion":
			_apply_speed_potion(potion)

		"Attack Speed Potion":
			_apply_attack_speed_potion(potion)

func _apply_speed_potion(potion: PotionData):
	move_speed *= potion.value
	await get_tree().create_timer(potion.duration).timeout
	move_speed /= potion.value

func _apply_attack_speed_potion(potion: PotionData):
	attack_speed_multiplier *= potion.value
	await get_tree().create_timer(potion.duration).timeout
	attack_speed_multiplier /= potion.value
