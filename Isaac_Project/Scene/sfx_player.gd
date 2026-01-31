extends AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
@onready var audio_player: AudioStreamPlayer2D = $".";
@onready var sfx_volume_bus = AudioServer.get_bus_index("SFX");
const sfx_map:= {
	"hurt": "res://Data/SFX/Hurt.wav",
	"mouse_hover": "res://Data/SFX/Hover.wav",
	"footsteps": "res://Data/SFX/Footstep.wav",
	"coin_pickup": "res://Data/SFX/CoinPickup.wav",
	"mask_pickup": "res://Data/SFX/MaskPickup.wav",
	"select": "res://Data/SFX/Select.wav",
	"spear_throw": "res://Data/SFX/Spear Throw.wav"
}

func _play_sfx(sfx_name):
	if sfx_map.has(sfx_name):
		var next_stream = load(sfx_map[sfx_name]);
		audio_player.stream = next_stream;
		audio_player.play();
