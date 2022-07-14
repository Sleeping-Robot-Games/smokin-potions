extends KinematicBody2D

export (int) var run_speed: int = 150
export (bool) var potion_cooldown_toogle: bool = false

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var game_scene: Node = null
#onready var player_start_node: Position2D = get_node("/root/Game/PlayerStart")

var type = "bot"
var number = '2'
var speed: int = run_speed
var velocity: Vector2 = Vector2()
var x_facing: String = "Right"
var x_changed: bool = false
var y_facing: String = "Back"
var y_changed: bool = false
var facing: String = "BackRight"
var cardinal_facing: String = "Right"
var animation: String = "Idle"
var new_facing: String = facing
var new_cardinal_facing: String = cardinal_facing
var movement_enabled = true
var potion_ready = true
var kicking_impulse = Vector2.ZERO
var kicking_potion = null
const KICK_FORCE = 200
const DIAG_KICK_FORCE = 100
var elements = []

var rng = RandomNumberGenerator.new()
var node_target = null
var dir = Vector2.ZERO

var mission_type = -1
var move_dir = ""
var move_coord = Vector2.ZERO

func _ready():
	speed = run_speed


func sprite_animation():
	new_facing = y_facing + x_facing
	if x_changed:
		new_cardinal_facing = x_facing
	elif y_changed:
		new_cardinal_facing = y_facing
	
	var new_animation = animation

	if kicking_impulse != Vector2.ZERO:
		velocity = Vector2.ZERO
		new_animation = "Kick"
	elif velocity == Vector2(0,0):
		new_animation = "Idle"
	elif velocity != Vector2(0,0):
		new_animation = "Run"
	
	if not movement_enabled and new_animation == "Run":
		new_animation = "Idle"
	
	if new_facing != facing or new_animation != animation:
		facing = new_facing
		animation = new_animation
		anim_player.play(animation + facing)
	
	if new_cardinal_facing != cardinal_facing:
		cardinal_facing = new_cardinal_facing


func _physics_process(delta):
	if "Kick" in anim_player.current_animation:
		return
	
	# MOVEMENT
	velocity = Vector2.ZERO
	if move_dir == "Left":
		velocity.x -= 1
	elif move_dir == "UpperLeft":
		velocity.x -= 1
		velocity.y -= 1
	elif move_dir == "Up":
		velocity.y -= 1
	elif move_dir == "UpperRight":
		velocity.x += 1
		velocity.y -= 1
	elif move_dir == "Right":
		velocity.x += 1
	elif move_dir == "LowerRight":
		velocity.x += 1
		velocity.y += 1
	elif move_dir == "Down":
		velocity.y += 1
	elif move_dir == "LowerLeft":
		velocity.x -= 1
		velocity.y += 1
	
	
	# ANIMATION
	var new_animation = animation
	if kicking_impulse != Vector2.ZERO:
		velocity = Vector2.ZERO
		new_animation = "Kick"
	elif velocity == Vector2(0,0):
		new_animation = "Idle"
	elif velocity != Vector2(0,0):
		new_animation = "Run"
	
	new_facing = facing if move_dir == "" else move_dir
	if facing != new_facing or new_animation != animation:
		facing = new_facing
		animation = new_animation
		anim_player.play(animation + facing)
	
	velocity = velocity.normalized() * speed
	move_and_slide(velocity)


func place_potion():
	if not potion_ready:
		return
	var p = g.get_potion_scene(elements).instance()
	
	# Places the potion in front of player
	var potion_position = global_position
	if cardinal_facing == 'Right':
		potion_position = Vector2(global_position.x + 20, global_position.y)
	if cardinal_facing == 'Left':
		potion_position = Vector2(global_position.x - 20, global_position.y)
	if cardinal_facing == 'Back':
		potion_position = Vector2(global_position.x, global_position.y - 30)
	if cardinal_facing == 'Front':
		potion_position = Vector2(global_position.x, global_position.y + 30)

	p.global_position = potion_position
	get_parent().add_child(p)
	# p.add_to_group(str(p.get_instance_id()))
	p.but_make_it_symmetrical(elements)
	
	# Clear elements after potion use
	elements = []
	g.emit_signal('elements_changed', elements)
	
	if potion_cooldown_toogle:
		potion_ready = false
		$PotionCooldown.start()


func _on_PotionCooldown_timeout():
	potion_ready = true


func _on_PickupArea_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if 'Rune' in area.get_parent().name:
		var rune = area.get_parent()
		if elements.size() == 2:
			elements.remove(1)
		elements.push_front(rune.element)
		g.emit_signal('elements_changed', elements)
		rune.cleanup()


func _on_PickupArea_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	pass


func _on_PickupArea_body_entered(body):
	pass


func _on_PickupArea_body_exited(body):
	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if "Kick" in anim_name:
		if kicking_potion and weakref(kicking_potion).get_ref():
			kicking_potion.kick(kicking_impulse)
		kicking_potion = null
		kicking_impulse = Vector2.ZERO


func _on_ThinkTimer_timeout():
	if mission_type == -1:
		var fresh_bombs = [] # safer to interact
		var scary_bombs = [] # about to blow
		for da_ray in $DeathAvoidance.get_children():
			if da_ray.is_colliding():
				var collider = da_ray.get_collider()
				# TODO factor in distance & speed
				if collider.get_node('ExplodeTimer').wait_time > 1:
					fresh_bombs.append(collider)
				else:
					scary_bombs.append(collider)
		var cap = 7 if fresh_bombs.size() > 0 or scary_bombs.size() > 0 else 4
		cap = 1 # TESTING
		rng.randomize()
		var decision = rng.randi_range(1, cap)
		# MOVE TO A RANDOM SPOT
		if decision == 1:
			var valid_coords = []
			var valid_dir = []
			var wall_collisions = []
			for w_ray in $Wall.get_children():
				if w_ray.is_colliding():
					wall_collisions.append(w_ray.name)
			for m_ray in $Move.get_children():
				if not m_ray.is_colliding() and not wall_collisions.has(m_ray.name):
					valid_coords.append(m_ray.cast_to)
					valid_dir.append(m_ray.name)
			if valid_dir.size() > 0:
				rng.randomize()
				var m = rng.randi_range(0, valid_dir.size() - 1)
				#mission_type = 1
				move_dir = valid_dir[m]
				move_coord = valid_coords[m]
#	determine_target()
#	if node_target and node_target.type == 'player':
#		chase_target(node_target)


func chase_target(target):
	var look = $NavRayCast
	look.cast_to = (target.global_position - global_position)
	look.force_raycast_update()
	
	# if we can see the target, chase it
	if !look.is_colliding():
		dir = look.cast_to_normalized()
	# of chase first scent we can see
	else:
		for scent in target.scent_trail:
			look.cast_to = (scent.global_position - global_position)
			look.force_raycast_update()
			
			if !look.is_colliding():
				dir = look.cast_to.normalized()
				break
	

func determine_target():
	var players = get_tree().get_nodes_in_group("players")
	players.erase(self)
	var breakables = get_tree().get_nodes_in_group("breakables")
	var nearest_player
	var nearest_breakable
	
	if players.size() > 0:
		nearest_player = nearest_target(players)
	
	#if breakables.size() > 0:
	#	nearest_ breakable = nearest_target(breakables)
	
	var nearest_targets = []
	if nearest_player:
		nearest_targets.append(nearest_player)
	if nearest_breakable:
		nearest_targets.append(nearest_breakable)
	
	node_target = nearest_target(nearest_targets)
	
	#print("node_target")
	#print(node_target)


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


func ponder_orb():
	dir = Vector2.ZERO
	

func _on_ScentTimer_timeout():
	pass # Player only
