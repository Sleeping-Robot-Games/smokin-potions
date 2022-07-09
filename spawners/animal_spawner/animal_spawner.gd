extends Node2D

onready var game = get_parent().get_parent()
var skeleton = preload("res://animals/skeleton/skeleton.tscn")


func spawn_animal(animal_scene):
	# determine spawn position and destination position
	var viewport = get_viewport().size
	var map = game.map.rect_size
	var spawn_x = 0
	var spawn_y = 0
	var destination_x = 0
	var destination_y = 0
	
	# spawn_area correlates to a [sN] spawn tile and matching [dN] destination tile
	# player camera limits (visibility) are represented by [vi] tiles
	# the map is represented by [mp] tiles
	#
	# [s0] [s1] [s2] [s3] [s4] [s5]
	# [s6] [vi] [vi] [vi] [vi] [s7]
	# [s8] [vi] [mp] [mp] [vi] [s9]
	# [d9] [vi] [mp] [mp] [vi] [d8]
	# [d7] [vi] [vi] [vi] [vi] [d6]
	# [d5] [d4] [d3] [d2] [d1] [d0]
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var spawn_area = rng.randi_range(0, 9)
	if spawn_area == 0:
		spawn_x = 0 - (viewport.x / 2) - 32
		spawn_y = 0 - (viewport.y / 2) - 32
		destination_x = map.x + (viewport.x / 2) + 32
		destination_y = map.y + (viewport.y / 2) + 32
	elif spawn_area == 1:
		spawn_x = 0 - (viewport.x / 4)
		spawn_y = 0 - (viewport.y / 2) - 32
		destination_x = map.x + (viewport.x / 4)
		destination_y = map.y + (viewport.y / 2) + 32
	elif spawn_area == 2:
		spawn_x = (map.x / 4)
		spawn_y = 0 - (viewport.y / 2) - 32
		destination_x = (map.x / 4) * 3
		destination_y = map.y + (viewport.y / 2) + 32
	elif spawn_area == 3:
		spawn_x = (map.x / 4) * 3
		spawn_y = 0 - (viewport.y / 2) - 32
		destination_x = (map.x / 4)
		destination_y = map.y + (viewport.y / 2) + 32
	elif spawn_area == 4:
		spawn_x = map.x + (viewport.x / 4)
		spawn_y = 0 - (viewport.y / 2) - 32
		destination_x = 0 - (viewport.x / 4)
		destination_y = map.y + (viewport.y / 2) + 32
	elif spawn_area == 5:
		spawn_x = map.x + (viewport.x / 2) + 32
		spawn_y = 0 - (viewport.y / 2) - 32
		destination_x = 0 - (viewport.x / 2) - 32
		destination_y = map.y + (viewport.y / 2) + 32
	elif spawn_area == 6:
		spawn_x = 0 - (viewport.x / 2) - 32
		spawn_y = 0 - (viewport.y / 4)
		destination_x = map.x + (viewport.x / 2) + 32
		destination_y = map.y + (viewport.y / 4)
	elif spawn_area == 7:
		spawn_x = map.x + (viewport.x / 2) + 32
		spawn_y = 0 - (viewport.y / 4)
		destination_x = 0 - (viewport.x / 2) - 32
		destination_y = map.y + (viewport.y / 4)
	elif spawn_area == 8:
		spawn_x = 0 - (viewport.x / 2) - 32
		spawn_y = 0
		destination_x = map.x + (viewport.x / 2) + 32
		destination_y = map.y
	elif spawn_area == 9:
		spawn_x = map.x + (viewport.x / 2) + 32
		spawn_y = 0
		destination_x = 0 - (viewport.x / 2) - 32
		destination_y = map.y
	var spawn_pos = Vector2(spawn_x, spawn_y)
	var destination_pos = Vector2(destination_x, destination_y)
	# spawn and initialize animal
	var animal_instance = animal_scene.instance()
	animal_instance.global_position = spawn_pos
	animal_instance.destination = destination_pos
	add_child(animal_instance)
	

func _on_SpawnTimer_timeout():
	# todo: factor in player count and make spawn logic more dynamic
	if game.difficulty == 0:
		spawn_animal(skeleton)
	elif game.difficulty == 1:
		spawn_animal(skeleton)
		spawn_animal(skeleton)
	elif game.difficulty == 2:
		spawn_animal(skeleton)
		spawn_animal(skeleton)
		spawn_animal(skeleton)
	elif game.difficulty >= 3:
		spawn_animal(skeleton)
		spawn_animal(skeleton)
		spawn_animal(skeleton)
		spawn_animal(skeleton)
