extends Node2D

var FT = preload("res://levels/float_text.tscn")

export var travel: Vector2 = Vector2(0, -80)
export var duration: int = 1
export var spread: float = PI/2

func float_text(value, color) -> void:
	var ft = FT.instance()
	add_child(ft)
	ft.float_text(str(value), color, travel, duration, spread)
