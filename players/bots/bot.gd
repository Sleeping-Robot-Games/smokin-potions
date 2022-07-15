extends 'res://players/player.gd'

var rng = RandomNumberGenerator.new()

var action_queue = []
onready var action_started = OS.get_ticks_msec()


func ready():
	number = '2'
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
		var delay = OS.get_ticks_msec() - action_queue[0]["start_time"]
		if delay >= action_queue[0]["delay"]:
			action_queue[0]["fn"].call_func()
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
	new_cardinal_facing = cardinal_facing
	if x_changed and new_cardinal_facing != x_facing:
		new_cardinal_facing = x_facing
	elif y_changed and new_cardinal_facing != y_facing:
		new_cardinal_facing = y_facing
	
	if new_cardinal_facing != cardinal_facing:
		cardinal_facing = new_cardinal_facing
	
	
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
	# only add more actions to the queue after we run out
	if action_queue.size() > 0:
		return
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
	cap = 4 # TESTING
	rng.randomize()
	var decision = rng.randi_range(1, cap)
	# MOVE TO A RANDOM SPOT
	if decision == 1:
		queue_action_random_move()
	# DROP AND KICK POTION (RANDOM DIRECTION)
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
	# DROP AND THROW POTION (VERY ROUGHLY TOWARDS RANDOM PLAYER)
	elif decision == 3:
		action_queue.append({
			"type": "FUNCTION",
			"fn": funcref(self, "place_potion"),
			"delay": 0,
			"timeout_ms": 1000,
			"start_time" : null,
			"name": "place_potion()",
		})
		action_queue.append({
			"type": "FUNCTION",
			"fn": funcref(self, "pickup_potion"),
			"delay": 500,
			"timeout_ms": 1000,
			"start_time" : null,
			"name": "pickup_potion()",
		})
		var targets = []
		for p in get_tree().get_nodes_in_group("players"):
			if not p.ghost:
				targets.append(p)
		rng.randomize()
		if targets.size() > 0:
			var t = rng.randi_range(0, targets.size() - 1)
			var target = null
			if t >= 0:
				target = targets[t]
			if target:
				var dir = dir_to_target(target)
				action_queue.append({
					"type": "MOVE",
					"dir": dir,
					"coord": target.global_position,
					"timeout_ms": 1000,
					"start_time" : null,
				})
		action_queue.append({
			"type": "FUNCTION",
			"fn": funcref(self, "throw_potion"),
			"delay": 500,
			"timeout_ms": 1000,
			"start_time" : null,
			"name": "throw_potion()",
		})
	# DROP A BOMB AND WALK AWAY
	elif decision == 4:
		place_potion()
		queue_action_random_move()

func queue_action_random_move():
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


func dir_to_target(target):
	var dir = global_position.direction_to(target.global_position)
	var precision = 0.25
	var y = ""
	var x = ""
	if dir.x <= precision * -1:
		x = "Left"
	elif dir.x >= precision:
		x = "Right"
	
	if dir.y <= precision * -1 and x == "":
		y = "Up"
	elif dir.y <= precision * -1 and x != "":
		y = "Upper"
	elif dir.y >= precision and x == "":
		y = "Down"
	elif dir.y >= precision and y != "":
		y = "Lower"
	
	return y + x


func pickup_potion():
	if !holding_potion and nearby_potions.size() > 0:
		holding_potion = nearby_potions.pop_back()
		holding_potion.get_held(self)
		for p_ray in $PotionRays.get_children():
			p_ray.add_exception(holding_potion)
		g.load_hold_assets(self, number)


func throw_potion():
	if holding_potion:
		holding_potion.get_thrown()
		holding_potion = null
		g.load_normal_assets(self, number)
		anim_player.play("Throw"+y_facing+x_facing)
