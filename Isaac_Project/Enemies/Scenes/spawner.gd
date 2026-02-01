extends Node2D

# GDScript
enum ENEMY_TYPES {NATIVE, WOLF, SNAKE}
@export var enemy_type: ENEMY_TYPES = ENEMY_TYPES.NATIVE
@export var wave_count: int = 3;
@export var enemy_min_count: int = 3;
@export var enemy_max_count: int = 5;
@export var spawn_pos: Array[Node2D];
@export var offset_range_min: float = 5.0;
@export var offset_range_max: float = 20.0;
@export var spawn_interval: float = 0.3;
var current_wave_count: int = 0;
var is_wave_complete: bool = true;
var current_enemy_count: int = 0;
var enemy_map := {
	ENEMY_TYPES.NATIVE: preload("res://Enemies/Scenes/Characters/Native.tscn"),
	ENEMY_TYPES.WOLF: preload("res://Enemies/Scenes/Characters/Wolf.tscn"),
	ENEMY_TYPES.SNAKE: preload("res://Enemies/Scenes/Characters/Snake.tscn")
}

func _ready():
	is_wave_complete = true
	spawn_enemy();
	
func spawn_enemy(): 
	while current_wave_count < wave_count:
		if is_wave_complete: 
			is_wave_complete = false;
			var spawn_amount = randi_range(enemy_min_count, enemy_max_count);
			current_enemy_count = spawn_amount;
			var count = 0;
			print("Spawned: " + str(spawn_amount))
			while count <= spawn_amount:
				print("Current spawn point: " + str(count % len(spawn_pos)))
				var new_enemy = enemy_map[enemy_type].instantiate();
				new_enemy.global_position = spawn_pos[count % len(spawn_pos)].global_position + Vector2(randf_range(offset_range_min, offset_range_max), randf_range(offset_range_min, offset_range_max));
				add_child(new_enemy)
				await get_tree().create_timer(spawn_interval).timeout 
				count += 1
		current_wave_count += 1;
	
	# Send signal to logs to unblock the road

func count_dead():
	current_enemy_count -= 1;
	if current_enemy_count <= 0:
		is_wave_complete = true;
	if is_wave_complete:
		spawn_enemy();
	
