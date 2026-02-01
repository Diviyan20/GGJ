extends Area2D

@export var value := 10

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.has_method("add_money"):
		body.add_money(value)
		SfxPlayer._play_sfx("coin_pickup");
		queue_free()
