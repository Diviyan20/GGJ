extends Control

func _ready():
	$AnimationPlayer.play("RESET")
func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blurring")

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blurring")

func testEsc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		resume()

func _on_resume_pressed() -> void:
	resume()


func _on_back_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")


func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()


func _process(delta):
	testEsc()
