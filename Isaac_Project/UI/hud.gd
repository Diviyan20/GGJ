extends CanvasLayer

@onready var wave_label = $WaveContainer/WaveLabel
@onready var room_clear_label = $RoomClearLabel

func _ready():
	room_clear_label.visible = false

func set_money(value: int):
	$MoneyContainer/MoneyLabel.text = str(value)

func set_wave(current: int, total: int):
	wave_label.text = "Wave %d / %d" % [current, total]

func show_room_clear():
	room_clear_label.visible = true
	room_clear_label.text = "[s]Room Clear[/s]"
	room_clear_label.bbcode_enabled = true
