extends Area2D
class_name EnemySpawner

signal wave_started(current_wave: int, total_wave: int)
signal room_cleared

enum ENEMY_TYPES {NATIVE, WOLF, SNAKE}

@onready var hud = get_parent().get_node("HUD")
@export var enemy_type: ENEMY_TYPES = ENEMY_TYPES.NATIVE
@export var wave_count: int = 3
@export var enemy_min_count: int = 3
@export var enemy_max_count: int = 5
@export var spawn_pos: Array[Node2D]
@export var offset_range_min: float = 5.0
@export var offset_range_max: float = 20.0
@export var spawn_interval: float = 0.3
@export var spawn_pattern: String = "circle"  # "random", "circle", "grid"
@export var min_spacing := 32.0
signal clear

# Native variants - export these for easy setup
@export_group("Native Variants")
@export var native_textures: Array[SpriteFrames] = []  # Add 3 textures in inspector

var current_wave_count: int = 0
var is_wave_complete: bool = true
var current_enemy_count: int = 0
var spawning_started: bool = false
var player_in_range: bool = false

var enemy_map := {
	ENEMY_TYPES.NATIVE: preload("res://Enemies/Scenes/Characters/Native.tscn"),
	ENEMY_TYPES.WOLF: preload("res://Enemies/Scenes/Characters/Wolf.tscn"),
	ENEMY_TYPES.SNAKE: preload("res://Enemies/Scenes/Characters/Snake.tscn")
}

func _ready():
	# Connect Area2D signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	wave_started.connect(_on_wave_started)
	room_cleared.connect(_on_room_cleared)
	
	# Setup collision to detect player
	collision_layer = 0  # Spawner doesn't need to be on a layer
	collision_mask = 1   # Detect layer 1 (Player)
	
	is_wave_complete = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		player_in_range = true
		if not spawning_started:
			spawning_started = true
			call_deferred("spawn_enemy")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		player_in_range = false

func spawn_enemy():
	await get_tree().process_frame
	_start_spawning()

func _start_spawning():
	while current_wave_count < wave_count:
		if is_wave_complete:
			is_wave_complete = false
			emit_signal("wave_started", current_wave_count + 1, wave_count)

			var spawn_amount = randi_range(enemy_min_count, enemy_max_count)
			current_enemy_count = spawn_amount

			for i in range(spawn_amount):
				spawn_one_enemy(i, spawn_amount)
				await get_tree().create_timer(spawn_interval).timeout

		current_wave_count += 1
		await wave_completed()

	emit_signal("room_cleared")

func spawn_one_enemy(index: int, total: int):
	var spawn_point = spawn_pos[index % spawn_pos.size()]
	var spawn_position: Vector2

	match spawn_pattern:
		"circle":
			spawn_position = get_circle_position(spawn_point.global_position, index, total)
		"grid":
			spawn_position = get_grid_position(spawn_point.global_position, index)
		_:
			spawn_position = spawn_point.global_position

	var new_enemy = enemy_map[enemy_type].instantiate()
	new_enemy.global_position = spawn_position

	if enemy_type == ENEMY_TYPES.NATIVE and native_textures.size() > 0:
		apply_native_variant(new_enemy)

	if new_enemy.has_signal("died"):
		new_enemy.died.connect(count_dead)
	elif new_enemy.has_node("Health"):
		new_enemy.get_node("Health").died.connect(count_dead)

	add_child.call_deferred(new_enemy)

func get_circle_position(center: Vector2, index: int, total: int) -> Vector2:
	var angle = (TAU / total) * index  # Evenly distribute around circle
	var radius = randf_range(offset_range_min, offset_range_max)
	return center + Vector2(cos(angle), sin(angle)) * radius

func get_grid_position(center: Vector2, index: int) -> Vector2:
	var cols = 3  # Enemies per row
	var row = index / cols
	var col = index % cols
	return center + Vector2(col * min_spacing, row * min_spacing) + Vector2(
		randf_range(-10, 10),  # Small random offset
		randf_range(-10, 10)
	)

func apply_native_variant(enemy: Node2D) -> void:
	if native_textures.size() == 0:
		push_warning("Warning: No native textures configured!")
		return
	
		# Get random SpriteFrames
	var random_frames = native_textures[randi() % native_textures.size()]
	
		# Use SuperSprite2D since that's the actual node name
	if enemy.has_node("SuperSprite2D"):
		var anim_sprite: AnimatedSprite2D = enemy.get_node("SuperSprite2D")
		anim_sprite.sprite_frames = random_frames
		anim_sprite.play("idle")
		print("Applied ", random_frames.resource_path, " to Native enemy")
	else:
		print("Error: Native enemy has no SuperSprite2D node")

func count_dead() -> void:
	current_enemy_count -= 1
	print("Enemy died. Remaining: ", current_enemy_count)
	
	if current_enemy_count <= 0:
		is_wave_complete = true

func wave_completed() -> void:
	while not is_wave_complete:
		await get_tree().create_timer(0.5).timeout

func _on_wave_started(current: int, total: int):
	hud.set_wave(current, total)

func _on_room_cleared():
	hud.show_room_clear()
