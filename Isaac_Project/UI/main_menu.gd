extends Node2D

@onready var startSprite := $ButtonManager/Start/AnimatedSprite2D
@onready var settingSprite := $ButtonManager/Setting/AnimatedSprite2D
@onready var quitSpirte := $ButtonManager/Quit/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	quitSpirte.play("default")
	settingSprite.play("default")
	startSprite.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/Level 1.tscn")


func _on_setting_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/Setting.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_quit_mouse_entered() -> void:
	quitSpirte.play("touch")
	await quitSpirte.animation_finished
	quitSpirte.play("hover")


func _on_setting_mouse_entered() -> void:
	settingSprite.play("touch")
	await settingSprite.animation_finished
	settingSprite.play("hover")


func _on_start_mouse_entered() -> void:
	startSprite.play("touch")
	await startSprite.animation_finished
	startSprite.play("hover")


func _on_quit_mouse_exited() -> void:
	quitSpirte.play("default")


func _on_setting_mouse_exited() -> void:
	settingSprite.play("default")


func _on_start_mouse_exited() -> void:
	startSprite.play("default")
