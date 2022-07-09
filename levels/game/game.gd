extends Node

var difficulty = 0
onready var camera = $Camera2D
onready var map = $Map
onready var difficulty_bar = $Camera2D/DifficultyBar

func _ready():
	set_camera_limits()
	get_tree().get_root().connect("size_changed", self, "_on_Screen_size_changed")


func set_camera_limits():
	var viewport = get_viewport().size
	var map_size = map.rect_size
	camera.limit_left = 0 - (viewport.x / 2)
	camera.limit_right = map_size.x + (viewport.x / 2)
	camera.limit_top = 0 - (viewport.y / 2)
	camera.limit_bottom = map_size.y + (viewport.y / 2)


func _on_DifficultyTimer_timeout():
	if difficulty_bar.value < difficulty_bar.max_value:
		difficulty_bar.value += 1
		difficulty = floor(difficulty_bar.value / 60)


func _on_Screen_size_changed():
	set_camera_limits()
