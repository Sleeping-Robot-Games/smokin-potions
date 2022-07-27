extends Node2D


func _ready():
	pass

func _process(delta):
	pass

func safe_zone():
	var safe_landing = true
	for cast in get_children():
		if cast is RayCast2D:
			if cast.is_colliding():
				safe_landing = false
	return safe_landing
