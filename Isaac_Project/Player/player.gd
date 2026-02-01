extends CharacterBody2D
class_name Player

@export var starting_mask: MaskData
@export var spear_scene: PackedScene
@export var aoe_radius := 96
@export var move_speed := 100.0
@export var starting_money := 999999999

var money := 0
var can_attack := true
var current_mask: MaskData = null
var aim_dir: Vector2 = Vector2.DOWN
var owned_masks: Array[MaskData] = []
var base_move_speed := move_speed
var attack_speed_multiplier := 1.0

@onready var hud = get_tree().get_first_node_in_group("hud")
@onready var wolf_attack_fx: AnimatedSprite2D = $WolfAttackEffect
@onready var health: Health = $Health

# Animation
enum mask_type {None, Godot, Native, Wolf}
@export var current_mask_sprite: mask_type = mask_type.None
@onready var player_anim: AnimatedSprite2D = $PlayerSprite
@onready var mask_anim: AnimatedSprite2D = $MaskSprite
var direction: Vector2
var current_facing: String = "front"

func _ready():
	player_anim.self_modulate = Color(1.0, 1.0, 1.0, 1.0);
	add_to_group("player")

	money = starting_money
	update_money_ui()

	if starting_mask:
		current_mask = starting_mask
		current_mask_sprite = _maskdata_to_enum(starting_mask)
		
		# Set player's entity type based on mask
		health.entity_type = starting_mask.mask_name

		# Directly play ON animation (no OFF on start)
		mask_anim.show()
		mask_anim.play(mask_type.keys()[current_mask_sprite] + "_on")

	health.died.connect(_on_died)

func update_money_ui():
	if hud:
		hud.set_money(money)

func _maskdata_to_enum(mask: MaskData) -> mask_type:
	match mask.mask_name:
		"Godot":
			return mask_type.Godot
		"Native":
			return mask_type.Native
		"Wolf":
			return mask_type.Wolf
		_:
			return mask_type.None


func equip_mask(mask: MaskData):
	current_mask = mask
	
	# Update player's entity type when mask changes
	health.entity_type = mask.mask_name

	if not owned_masks.has(mask):
		owned_masks.append(mask)

	var new_mask_enum := _maskdata_to_enum(mask)
	await change_mask(new_mask_enum)

	print("Equipped mask:", mask.mask_name)


func Movement():
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	# player_animation
	if direction.y > 0:
		current_facing = "front"
	elif direction.y < 0:
		current_facing = "back"
	elif direction.x > 0:
		current_facing = "right"
	elif direction.x < 0:
		current_facing = "left"


func Char_player_animation():
	if direction == Vector2.ZERO:
		player_anim.play("Idle_"+current_facing)
	else:
		player_anim.play("Walk_"+current_facing)


func change_mask(new_mask: mask_type) -> void:
	if current_mask_sprite == new_mask:
		return

	# Destroy old mask
	if current_mask_sprite != mask_type.None:
		mask_anim.play(mask_type.keys()[current_mask_sprite] + "_off")
		await mask_anim.animation_finished

	current_mask_sprite = new_mask

	# Equip new mask
	if new_mask == mask_type.None:
		mask_anim.hide()
	else:
		mask_anim.show()
		mask_anim.play(mask_type.keys()[new_mask] + "_on")

func _physics_process(delta):
	Movement()
	Char_player_animation()
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
	spear.rotation = aim_dir.angle()
	spear.damage = current_mask.attack_damage
 	#spear.attacker_type = current_mask.mask_name

func attack_wolf():
	# 1️⃣ Position & rotate attack area
	$AttackArea.global_position = global_position + aim_dir * 35
	$AttackArea.rotation = aim_dir.angle()

	# 2️⃣ Play swing effect
	wolf_attack_fx.visible = true
	wolf_attack_fx.global_position = $AttackArea.global_position;
	wolf_attack_fx.rotation = $AttackArea.rotation;
	wolf_attack_fx.play("wolf_swing")
	$Camera2D.offset = Vector2(randf_range(-2,2), randf_range(-2,2))

	# 3️⃣ Deal damage to enemies in range
	for body in $AttackArea.get_overlapping_bodies():
		if body == self:
			continue
		if body.has_node("Health"):
			var enemy_health: Health = body.get_node("Health")
			enemy_health.take_damage(current_mask.attack_damage, current_mask.mask_name)

	# 4️⃣ Hide effect after animation
	await wolf_attack_fx.animation_finished
	wolf_attack_fx.visible = false

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
		if body.has_node("Health"):
			var enemy_health: Health = body.get_node("Health")
			enemy_health.take_damage(current_mask.attack_damage)

# ----------------
# DAMAGE SYSTEM
# ----------------
func take_damage(amount: float) -> void:
	health.take_damage(amount)
	var camera := $Camera2D
	camera.shake(1.0)

func heal(amount: float) -> void:
	health.heal(amount)

func _on_died() -> void:
	print("Player died")
	# Game over logic here

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
			health.heal(5.0)

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
