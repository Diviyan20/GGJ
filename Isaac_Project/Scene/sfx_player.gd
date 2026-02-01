extends Node2D;

# Called when the node enters the scene tree for the first time.
@onready var sfx_volume_bus = AudioServer.get_bus_index("SFX");
const sfx_map:= {
	"hurt": preload("res://Data/SFX/Hurt.wav"),
	"mouse_hover": preload("res://Data/SFX/Hover.wav"),
	"footsteps": preload("res://Data/SFX/Footstep.wav"),
	"coin_pickup": preload("res://Data/SFX/CoinPickup.wav"),
	"mask_pickup": preload("res://Data/SFX/MaskPickup.wav"),
	"select": preload("res://Data/SFX/Select.wav"),
	"spear_throw": preload("res://Data/SFX/Spear Throw.wav")
}

func _play_sfx(sfx_name):
	if sfx_map.has(sfx_name):
		run_sfx(sfx_map[sfx_name]);


func run_sfx(stream: AudioStream):
	if stream == null:
		return;

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "SFX"
	add_child(player)
	player.pitch_scale = randf_range(0.90, 1.10);
	player.play()
	player.finished.connect(player.queue_free)
