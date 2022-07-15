extends KinematicBody2D

export (int) var run_speed: int = 150
export (bool) var potion_cooldown_toogle: bool = false
export (bool) var disabled: bool = false

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var game_scene: Node = null
#onready var player_start_node: Position2D = get_node("/root/Game/PlayerStart")

var type = "bot"
var number = '2'
var health = 2
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
var nearby_potions = []
var holding_potion: RigidBody2D
var ghost = false

var rng = RandomNumberGenerator.new()
var node_target = null
var dir = Vector2.ZERO

#var mission_type = -1
var action_queue = []
onready var action_started = OS.get_ticks_msec()

func _ready():
	speed = run_speed
	for d_ray in $DangerRays.get_children():
		d_ray.add_exception(self)
	for m_ray in $MoveRays.get_children():
		m_ray.add_exception(self)
	for s_ray in $SidestepRays.get_children():
		s_ray.add_exception(self)
	for w_ray in $WallRays.get_children():
		w_ray.add_exception(self)


func invert_dir(d):
	if d == "Left":
		return "Right"
	elif d == "UpperLeft":
		return "LowerRight"
	elif d == "Up":
		return "Down"
	elif d == "UpperRight":
		return "LowerLeft"
	elif d == "Right":
		return "Left"
	elif d == "LowerRight":
		return "UpperLeft"
	elif d == "Down":
		return "Up"
	elif d == "LowerLeft":
		return "UpperRight"


func remove_action():
	action_queue.remove(0)
	if action_queue.size() > 0:
		action_queue[0]["start_time"] = OS.get_ticks_msec()


func _physics_process(delta):
	if disabled or "Kick" in anim_player.current_animation:
		return
	
	# if current action hasn't been started, do so now
	if action_queue.size() > 0 and not action_queue[0]["start_time"]:
		action_queue[0]["start_time"] = OS.get_ticks_msec()
	
	# drop current action if it's expired or if type is movement and we're within 5 px of target
	if action_queue.size() > 0 and (OS.get_ticks_msec() - action_queue[0]["start_time"] > action_queue[0]["timeout_ms"]  or (action_queue[0]["type"] == "MOVE" and global_position.distance_to(action_queue[0]["coord"]) < 5)):
		remove_action()
	
	# if current action is a function and we've waited long enough, call it
	if action_queue.size() > 0 and action_queue[0]["type"] == "FUNCTION":
		if OS.get_ticks_msec() - action_queue[0]["start_time"] >= action_queue[0]["delay"]:
			action_queue[0]["fn"]
			remove_action()
	
	# DIRECTION
	velocity = Vector2.ZERO
	if action_queue.size() > 0 and action_queue[0]["type"] == "MOVE":
		if action_queue[0]["dir"] == "Left":
			velocity.x -= 1
		elif action_queue[0]["dir"] == "UpperLeft":
			velocity.x -= 1
			velocity.y -= 1
		elif action_queue[0]["dir"] == "Up":
			velocity.y -= 1
		elif action_queue[0]["dir"] == "UpperRight":
			velocity.x += 1
			velocity.y -= 1
		elif action_queue[0]["dir"] == "Right":
			velocity.x += 1
		elif action_queue[0]["dir"] == "LowerRight":
			velocity.x += 1
			velocity.y += 1
		elif action_queue[0]["dir"] == "Down":
			velocity.y += 1
		elif action_queue[0]["dir"] == "LowerLeft":
			velocity.x -= 1
			velocity.y += 1
	
	x_changed = velocity.x != 0
	x_facing = x_facing
	if x_changed and velocity.x < 0:
		x_facing = "Left"
	elif x_changed and velocity.x > 0:
		x_facing = "Right"
	
	y_changed = velocity.y != 0
	y_facing = y_facing
	if y_changed and velocity.y < 0:
		y_facing = "Back"
	elif y_changed and velocity.y > 0:
		y_facing = "Front"	
	
	new_facing = y_facing + x_facing
	if x_changed:
		new_cardinal_facing = x_facing
	elif y_changed:
		new_cardinal_facing = y_facing
	
	# KICKING
	for p_ray in $PotionRays.get_children():
		p_ray.force_raycast_update()
	if $PotionRays/Left.is_colliding() and "Left" in new_facing:
		var collider = $PotionRays/Left.get_collider()
		kicking_impulse = Vector2(KICK_FORCE * -1, 0)
		kicking_potion = collider
	elif $PotionRays/UpperLeft.is_colliding() and new_facing == "BackLeft":
		var collider = $PotionRays/UpperLeft.get_collider()
		kicking_impulse = Vector2(DIAG_KICK_FORCE * -1, DIAG_KICK_FORCE * -1)
		kicking_potion = collider
	elif $PotionRays/Up.is_colliding() and "Back" in new_facing:
		var collider = $PotionRays/Up.get_collider()
		kicking_impulse = Vector2(0, KICK_FORCE * -1)
		kicking_potion = collider
	elif $PotionRays/UpperRight.is_colliding() and new_facing == "BackRight":
		var collider = $PotionRays/UpperRight.get_collider()
		kicking_impulse = Vector2(DIAG_KICK_FORCE, DIAG_KICK_FORCE * -1)
		kicking_potion = collider
	elif $PotionRays/Right.is_colliding() and "Right" in new_facing:
		var collider = $PotionRays/Right.get_collider()
		kicking_impulse = Vector2(KICK_FORCE, 0)
		kicking_potion = collider
	elif $PotionRays/LowerRight.is_colliding()  and new_facing == "FrontRight":
		var collider = $PotionRays/LowerRight.get_collider()
		kicking_impulse = Vector2(DIAG_KICK_FORCE, DIAG_KICK_FORCE)
		kicking_potion = collider
	elif $PotionRays/Down.is_colliding() and "Front" in new_facing:
		var collider = $PotionRays/Down.get_collider()
		kicking_impulse = Vector2(0, KICK_FORCE)
		kicking_potion = collider
	elif $PotionRays/LowerLeft.is_colliding() and new_facing == "FrontLeft":
		var collider = $PotionRays/LowerLeft.get_collider()
		kicking_impulse = Vector2(DIAG_KICK_FORCE * -1, DIAG_KICK_FORCE)
		kicking_potion = collider
	else:
		kicking_impulse = Vector2.ZERO
	
	# ANIMATION
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
	
	
	# MOVEMENT
	velocity = velocity.normalized() * speed
	move_and_slide(velocity)


func _on_ThinkTimer_timeout():
	scheme()


func scheme():
	if action_queue.size() == 0:
		var fresh_bombs = [] # safer to interact
		var scary_bombs = [] # about to blow
		for d_ray in $DangerRays.get_children():
			d_ray.force_raycast_update()
			if d_ray.is_colliding():
				var collider = d_ray.get_collider()
				# TODO factor in distance & speed
				if collider.get_node('ExplodeTimer') and collider.get_node('ExplodeTimer').wait_time > 1:
					fresh_bombs.append(collider)
				else:
					scary_bombs.append(collider)
		var cap = 7 if fresh_bombs.size() > 0 or scary_bombs.size() > 0 else 4
		cap = 3 # TESTING
		rng.randomize()
		var decision = rng.randi_range(1, cap)
		# MOVE TO A RANDOM SPOT
		if decision == 1:
			var valid_coords = []
			var valid_dir = []
			var wall_collisions = []
			for w_ray in $WallRays.get_children():
				w_ray.force_raycast_update()
				if w_ray.is_colliding():
					wall_collisions.append(w_ray.name)
			for m_ray in $MoveRays.get_children():
				m_ray.force_raycast_update()
				if not m_ray.is_colliding() and not wall_collisions.has(m_ray.name):
					valid_coords.append(m_ray.to_global(m_ray.cast_to))
					valid_dir.append(m_ray.name)
			if valid_dir.size() > 0:
				rng.randomize()
				var m = rng.randi_range(0, valid_dir.size() - 1)
				action_queue.append({
					"type": "MOVE",
					"dir": valid_dir[m],
					"coord": valid_coords[m],
					"timeout_ms": 2000,
					"start_time" : null,
				})
		elif decision == 2:
			var valid_coords = []
			var valid_dir = []
			for s_ray in $SidestepRays.get_children():
				s_ray.force_raycast_update()
				if not s_ray.is_colliding():
					valid_coords.append(s_ray.to_global(s_ray.cast_to))
					valid_dir.append(s_ray.name)
			if valid_dir.size() > 0:
				place_potion()
				rng.randomize()
				var m = rng.randi_range(0, valid_dir.size() - 1)
				action_queue.append({
					"type": "MOVE",
					"dir": valid_dir[m],
					"coord": valid_coords[m],
					"timeout_ms": 1000,
					"start_time" : null,
				})
				action_queue.append({
					"type": "MOVE",
					"dir": invert_dir(valid_dir[m]),
					"coord": Vector2(valid_coords[m].x * -1, valid_coords[m].y * -1),
					"timeout_ms": 1000,
					"start_time" : null,
				})
		elif decision == 3:
			place_potion()
			action_queue.append({
				"type": "FUNCTION",
				"fn": pickup_potion(),
				"delay": 500,
				"timeout_ms": 1000,
				"start_time" : null,
			})
			action_queue.append({
				"type": "FUNCTION",
				"fn": throw_potion(),
				"delay": 500,
				"timeout_ms": 1000,
				"start_time" : null,
			})


func pickup_potion():
	print("PICKING UP POTION")
	if !holding_potion and nearby_potions.size() > 0:
		holding_potion = nearby_potions.pop_back()
		print("PICKED UP: " + holding_potion.name)
		holding_potion.get_held(self)
		for p_ray in $PotionRays.get_children():
			p_ray.add_exception(holding_potion)
		g.load_hold_assets(self, number)
	else:
		print("nothing to pickup :( -- " + str(!holding_potion) + ", " + str(nearby_potions.size()))

func throw_potion():
	print("THROWING POTIONS")
	if holding_potion:
		print("THROWING: " + holding_potion.name + ", Throw"+y_facing+x_facing)
		holding_potion.get_thrown()
		holding_potion = null
		g.load_normal_assets(self, number)
		anim_player.play("Throw"+y_facing+x_facing)
	else:
		print("nothing to throw :(")


func place_potion():
	print("PLACING POTION")
	if not potion_ready:
		print("aborted placing potion (not ready)")
		return
	var p = g.get_potion_scene(elements).instance()
	p.global_position = global_position
	p.parent_player = self
	get_parent().add_child(p)
	p.but_make_it_symmetrical(elements)
	nearby_potions.append(p)
	
	
	# Clear elements after potion use
	elements = []
	g.emit_signal('elements_changed', elements, number)
	
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
		g.emit_signal('elements_changed', elements, number)
		rune.cleanup()


func take_dmg(dmg):
	health -= dmg
	if health == 0:
		ghost = true
		self_modulate = Color(1, 1, 1, .25)
	if health >= 1:
		g.emit_signal('health_changed', number, health)

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
#		if move_dir.size() > 0:
#			move_dir.remove(0)
#			move_coord.remove(0)
#			scheme()
	if "Throw" in anim_name:
		anim_player.play("Idle"+y_facing+x_facing)


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
	
func get_stunned():
	disabled = true
	$StunnedTimer.start()
	
func _on_StunnedTimer_timeout():
	disabled = false

func _on_ScentTimer_timeout():
	pass # Player only


func _on_BombPickupArea_area_entered(area):
	if area.name == 'PotionPickupArea' and nearby_potions.find(area.get_parent()) == -1 and !area.get_parent().potion_daddy:
		print("NEARBY_POTION ENTERED")
		var potion = area.get_parent()
		nearby_potions.append(potion)


func _on_BombPickupArea_area_exited(area):
	if area.name == 'PotionPickupArea' and nearby_potions.find(area.get_parent()) != -1:
		print("NEARBY_POTION EXITED")
		var potion = area.get_parent()
		nearby_potions.erase(potion)
