extends Camera2D

@export var shake_decay := 8.0
@export var max_offset := Vector2(6, 6)

var shake_strength := 0.0
var noise := FastNoiseLite.new()
var noise_i := 0.0

func _ready():
	noise.seed = randi()
	noise.frequency = 30.0
	

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
		noise_i += delta * 50

		offset = Vector2(
			noise.get_noise_1d(noise_i) * max_offset.x,
			noise.get_noise_1d(noise_i + 1000) * max_offset.y
		) * shake_strength
	else:
		offset = Vector2.ZERO

func shake(intensity := 1.0):
	shake_strength = clamp(shake_strength + intensity, 0.0, 1.0)
