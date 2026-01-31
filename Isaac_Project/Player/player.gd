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
var current_mask_name := ""
var aim_dir: Vector2 = Vector2.DOWN
var owned_masks: Array[MaskData] = []
var base_move_speed := move_speed
var attack_speed_multiplier := 1.0

enum Facing { FRONT, BACK, SIDE }
var facing := Facing.FRONT

@onready var hud = get_tree().get_first_node_in_group("hud")
@onready var mask_sprite_main: AnimatedSprite2D = $MaskSprite2

func _ready():
	money = starting_money
	update_money_ui()

	hp = max_hp
	update_hp_bar()

	mask_sprite_main.visible = false

	if starting_mask:
		equip_mask(starting_mask)
	
func change_mask(anim_name:String):
	mask_sprite_main.play(anim_name)

func update_money_ui():
	if hud:
		hud.set_money(money)


func equip_mask(mask: MaskData):
	# If a mask is already equipped → destroy it first
	if current_mask_name != "":
		await _play_mask_destroy(current_mask_name)

	current_mask = mask
	current_mask_name = mask.mask_name

	# Equip new mask
	await _play_mask_equip(mask.mask_name)

	print("Equipped mask:", mask.mask_name)

func _play_mask_destroy(mask_name: String):
	var anim_name := "destroy_%s" % mask_name.to_lower()

	if not mask_sprite_main.sprite_frames.has_animation(anim_name):
		return

	mask_sprite_main.visible = true
	mask_sprite_main.play(anim_name)

	await mask_sprite_main.animation_finished

	mask_sprite_main.visible = false

func _play_mask_equip(mask_name: String):
	var anim_name := "equip_%s" % mask_name.to_lower()

	if not mask_sprite_main.sprite_frames.has_animation(anim_name):
		push_error("Missing animation: " + anim_name)
		return

	mask_sprite_main.visible = true
	mask_sprite_main.play(anim_name)

	await mask_sprite_main.animation_finished


#func _set_mask_texture(mask_name: String):
	#match mask_name:
		#"Wolf":
			#$MaskSprite.texture = preload("res://Sprite/mask/tile162.png")
		#"Native":
			#$MaskSprite.texture = preload("res://Sprite/mask/tile161.png")
		#"Godot":
			#$MaskSprite.texture = preload("res://Sprite/mask/tile160.png")

func _physics_process(delta):
	handle_movement()
	update_aim_direction()

func update_facing(input_dir: Vector2):
	if input_dir == Vector2.ZERO:
		return

	if abs(input_dir.x) > abs(input_dir.y):
		facing = Facing.SIDE
	else:
		if input_dir.y < 0:
			facing = Facing.BACK
		else:
			facing = Facing.FRONT

func update_sprite(input_dir: Vector2):
	var sprite := $Sprite2D
	var anim := $Sprite2D/AnimationPlayer


	match facing:
		Facing.FRONT:
			anim.play("walk_backward")
			sprite.flip_h = false

		Facing.BACK:
			anim.play("walk_forward")
			sprite.flip_h = false

		Facing.SIDE:
			anim.play("walk_side")
			sprite.flip_h = input_dir.x < 0




func handle_movement():
	var input_dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		update_facing(input_dir)
		update_sprite(input_dir)

	velocity = input_dir * get_move_speed()
	move_and_slide()

func get_move_speed() -> float:
	var speed := move_speed
	if current_mask:
		speed *= current_mask.speed_multiplier
	return speed * attack_speed_multiplier

func take_damage(amount: int, attacker_mask := ""):
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
		if body == self:
			continue
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
