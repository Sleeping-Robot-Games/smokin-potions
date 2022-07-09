extends KinematicBody2D

export (int) var move_speed = 120
export (int) var vision_range = 80
export (String, 'Left', 'Right', 'Front', 'Back') var default_facing = 'Front'

onready var anim_player = $AnimationPlayer

var type = "animal"
var despawn_if_offscreen = false
var facing = "Right"
var velocity = Vector2.ZERO
var destination = Vector2.ZERO
var plants: Array = []
var saplings: Array = []
var players: Array = []
var node_target = null


func _physics_process(delta):
	# only despawn if off screen after animal has first appeared on screen
	# todo: change this so it is not based on camera visibility (will be different per player),
	#       and instead use a short timer or check if enemy is within map boundaries
	if not despawn_if_offscreen and get_node("VisibilityNotifier2D").is_on_screen():
		despawn_if_offscreen = true
	elif despawn_if_offscreen and not get_node("VisibilityNotifier2D").is_on_screen():
		queue_free()
	
	# determine if nearby node should override destination for pathing
	determine_target()
	
	# move towards target
	var target_pos = destination
	if node_target:
		target_pos = node_target.global_position
	velocity = global_position.direction_to(target_pos) * move_speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		pass
	
	# animate sprite based on movement direction
	animate_sprite(global_position, target_pos)


func animate_sprite(from, to):
	# determine which way to face animal based on prior position
	var dir = from.direction_to(to)
	var dominant_axis = "x" if abs(dir.x) > abs(dir.y) else "y"
	var new_facing = facing
	if dominant_axis == "x":
		new_facing = "Right" if dir.x > 0 else "Left"
	else:
		new_facing = "Front" if dir.y > 0 else "Back"

	anim_player.play("Walk" + new_facing)
		
	# animate animal in appropriate direction
	if facing != new_facing:
		facing = new_facing
		anim_player.play("Walk" + facing)


func determine_target():
	# 1. plants prioritized over saplings prioritized over players
	# 2. nearest node within target group prioritized over farther nodes
	var vulnerable_plants = get_vulnerable_targets(plants)
	var vulnerable_saplings = get_vulnerable_targets(saplings)
	var vulnerable_players = get_vulnerable_targets(players)
	node_target = null
	if vulnerable_plants.size() > 0:
		node_target = nearest_target(vulnerable_plants)
	elif vulnerable_saplings.size() > 0:
		node_target = nearest_target(vulnerable_saplings)
	elif vulnerable_players.size() > 0:
		node_target = nearest_target(vulnerable_players)


func get_vulnerable_targets(targets: Array):
	var vulnerable_targets = []
	if targets.size() > 0:
		for target in targets:
			if not target.get("is_invulnerable"):
				vulnerable_targets.push_back(target)
	return vulnerable_targets


func nearest_target(targets: Array):
	if targets.size() <= 0:
		return null
	var nearest_target = targets[0]
	for target in targets:
		var cur_target_distance = global_position.distance_to(nearest_target.global_position)
		var new_target_distance = global_position.distance_to(target.global_position)
		if new_target_distance < cur_target_distance:
			nearest_target = target
	return nearest_target


func _on_DetectionArea_body_entered(body):
	# skip processing if body does not have type variable, or is invulnerable
	if not body.get("type") or body.get("is_invulnerable"):
		return
	# otherwise, add to appropriate array depending on type
	if body.type == "plant":
		plants.push_back(body)
	elif body.type == "sapling":
		saplings.push_back(body)
	elif body.type == "player":
		players.push_back(body)


func _on_DetectionArea_body_exited(body):
	# skip processing if body does not have type variable
	if not body.get("type"):
		return
	# otherwise, remove from appropriate array depending on type
	if body.type == "plant":
		plants.erase(body)
	elif body.type == "sapling":
		saplings.erase(body)
	elif body.type == "player":
		players.erase(body)

