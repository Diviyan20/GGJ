extends Node2D

@onready var camera: Camera2D = %Camera2D;
@export var camera_move_speed: float = 0.7;

func _on_area_2d_area_entered(collider: Area2D) -> void:
	if collider.is_in_group("player"):
		# camera.global_position = global_position;
		move_camera();

func move_camera() -> void:
	var tween = create_tween()
	tween.tween_property(camera, "global_position", global_position, camera_move_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
