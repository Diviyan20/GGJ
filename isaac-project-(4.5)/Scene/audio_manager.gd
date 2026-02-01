extends AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
const exploration_mode:String = "res://Data/Songs/The Winds of Wild.mp3";
const battle_mode:String  = "res://Data/Songs/Welcome to the Jungle of Hell.mp3";
@onready var audio_player: AudioStreamPlayer2D = $".";
@export var is_battle: bool = false;

@onready var bgm_volume_bus = AudioServer.get_bus_index("BGM");


func _ready() -> void:
	_on_scene_changed(is_battle);

func _on_scene_changed(in_battle):
	if in_battle == null:
		return
	if in_battle:
		var next_stream = load(battle_mode);
		if audio_player.stream != next_stream:
			fade_to(next_stream, 1.0);
	else:
		var next_stream = load(exploration_mode);
		if audio_player.stream != next_stream:
			fade_to(next_stream, 1.0);

func fade_to(new_stream: AudioStream, duration: float = 1.0) -> void:
	var start_vol_db = audio_player.volume_db
	var end_vol_db = -50.0  # minimum volume = silent
	
	# Fade out
	var time_passed = 0.0
	while time_passed < duration:
		var t = time_passed / duration
		volume_db = lerp(start_vol_db, end_vol_db, t)
		await get_tree().process_frame
		time_passed += get_process_delta_time()
	
	# Switch stream
	audio_player.stream = new_stream
	audio_player.play()
	
	# Fade in
	time_passed = 0.0
	while time_passed < duration:
		var t = time_passed / duration
		volume_db = lerp(end_vol_db, start_vol_db, t)
		await get_tree().process_frame
		time_passed += get_process_delta_time()
	
	volume_db = start_vol_db  # ensure final volume is exact
