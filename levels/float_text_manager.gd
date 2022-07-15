extends Node2D

var FT = preload("res://levels/float_text.tscn")

export var travel: Vector2 = Vector2(0, -80)
export var duration: int = 1
export var spread: float = PI/2

func float_text(value, is_positive: bool = true) -> void:
	var ft = FT.instance()
	add_child(ft)
	if is_positive:
		ft.float_text("+" + str(value), Color(0,1,0,1), travel, duration, spread)
	else:
		ft.float_text("-" + str(value), Color(1,0,0,1), travel, duration, spread)
