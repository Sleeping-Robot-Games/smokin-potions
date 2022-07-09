extends Node2D

onready var game = get_parent().get_parent()
var helicopter_seed = preload("res://floating_seeds/helicopter_seed/helicopter_seed.tscn")

func spawn_seed(seed_scene):
	# determine spawn position and destination position
	var viewport = get_viewport().size
	var map = game.map.rect_size
	
	# determine spawn position
	var spawn_x = 0
	var spawn_y = 0
	var offscreen_left = 0 - (viewport.x / 2) - 32
	var offscreen_right = map.x + (viewport.x / 2) + 32
	var offscreen_top = 0 - (viewport.y / 2) - 32
	var offscreen_bottom = map.y + (viewport.y / 2) + 32
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var spawn_area = rng.randi_range(0, 3)
	rng.randomize()
	# left
	if spawn_area == 0:
		spawn_x = offscreen_left
		spawn_y = rng.randi_range(offscreen_top, offscreen_bottom)
	# right
	elif spawn_area == 1:
		spawn_x = offscreen_right
		spawn_y = rng.randi_range(offscreen_top, offscreen_bottom)
	# top
	elif spawn_area == 2:
		spawn_x = rng.randi_range(offscreen_left, offscreen_right)
		spawn_y = offscreen_top
	# bottom
	elif spawn_area == 3:
		spawn_x = rng.randi_range(offscreen_left, offscreen_right)
		spawn_y = offscreen_bottom
	var spawn_pos = Vector2(spawn_x, spawn_y)
	
	# determine destination position
	rng.randomize()
	var destination_x = rng.randi_range(32, map.x - 32)
	rng.randomize()
	var destination_y = rng.randi_range(32, map.y - 32)
	var destination_pos = Vector2(destination_x, destination_y)
	
	# spawn and initialize animal
	var seed_instance = seed_scene.instance()
	seed_instance.global_position = spawn_pos
	seed_instance.spawn = spawn_pos
	seed_instance.destination = destination_pos
	add_child(seed_instance)


func _on_SpawnTimer_timeout():
	# todo: factor in player count and make spawn logic more dynamic
	if game.difficulty == 0:
		spawn_seed(helicopter_seed)
	elif game.difficulty == 1:
		spawn_seed(helicopter_seed)
		spawn_seed(helicopter_seed)
	elif game.difficulty == 2:
		spawn_seed(helicopter_seed)
		spawn_seed(helicopter_seed)
		spawn_seed(helicopter_seed)
	elif game.difficulty >= 3:
		spawn_seed(helicopter_seed)
		spawn_seed(helicopter_seed)
		spawn_seed(helicopter_seed)
		spawn_seed(helicopter_seed)
