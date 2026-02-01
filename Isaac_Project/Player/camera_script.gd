extends Node2D

@onready var camera: Camera2D = %Camera2D;
@export var camera_move_speed: float = 0.7;
@export var has_enemies: bool = false;
@export var doors: Array[Node2D];
@export var colliders: Array[CollisionShape2D];
var is_cleared: bool = false
@export var room_spawner: EnemySpawner;

func _ready():
	for door in doors:
		door.visible = false;
	for collider in colliders:
		collider.set_deferred("disabled", true);

func _on_area_2d_area_entered(collider: Area2D) -> void:
	if collider.is_in_group("player"):
		# camera.global_position = global_position;
		move_camera();
		if has_enemies:
			if !is_cleared:
				room_spawner.spawn_enemy();
				if len(doors) > 0:
					for door in doors:
						door.visible = true;
					for door in colliders:
						door.set_deferred("disabled", false);
			BgmPlayer._on_scene_changed(true)


func room_cleared():
	is_cleared = true;
	for door in doors:
		door.visible = false;
	BgmPlayer._on_scene_changed(false)

func move_camera() -> void:
	var tween = create_tween()
	tween.tween_property(camera, "global_position", global_position, camera_move_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
