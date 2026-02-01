extends Node


signal wave_changed(current: int, total: int)

func wave_started(current: int, total: int):
	wave_changed.emit(current, total)
