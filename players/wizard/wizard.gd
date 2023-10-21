extends 'res://players/player.gd'
# warning-ignore-all:return_value_discarded

func ready():
	pass


func get_input():
	velocity = Vector2()
	if $IceRay.is_colliding():
		if cardinal_facing == "Right":
			velocity.x += 1
		elif cardinal_facing == "Left":
			velocity.x -= 1
		elif cardinal_facing == "Front":
			velocity.y += 1
		elif cardinal_facing == "Back":
			velocity.y -= 1
	else:
		if Input.is_action_pressed("right_"+controller_num):
			velocity.x += 1
		if Input.is_action_pressed("left_"+controller_num):
			velocity.x -= 1
		if Input.is_action_pressed("down_"+controller_num):
			velocity.y += 1
		if Input.is_action_pressed("up_"+controller_num):
			velocity.y -= 1
	
	if movement_enabled:
		velocity = velocity.normalized() * speed

	# store necessary information to determine which way to face player in sprite_animation()
	# x axis
	x_changed = false
	if Input.is_action_pressed("right_"+controller_num) and Input.is_action_pressed("left_"+controller_num):
		x_facing = x_facing
	elif Input.is_action_pressed("right_"+controller_num):
		x_facing = "Right"
		x_changed = true
	elif Input.is_action_pressed("left_"+controller_num):
		x_facing = "Left"
		x_changed = true
	# y axis
	y_changed = false
	if Input.is_action_pressed("up_"+controller_num) and Input.is_action_pressed("down_"+controller_num):
		y_facing = y_facing
	elif Input.is_action_pressed("up_"+controller_num):
		y_facing = "Back"
		y_changed = true
	elif Input.is_action_pressed("down_"+controller_num):
		y_facing = "Front"
		y_changed = true

	# whenever player moves, update dropkick_velocity to be the last known 
	if x_changed :
		dropkick_velocity.x = -1 if x_facing == "Left" else 1
		var prev_y_changed = false
		for buffer in diag_kick_frames:
			if buffer["up_released"] or buffer["down_released"]:
				dropkick_velocity.y = -1 if buffer["up_released"] else 1
				prev_y_changed = true
				break
		if not y_changed and not prev_y_changed:
			dropkick_velocity.y = 0
	if y_changed:
		dropkick_velocity.y = -1 if y_facing == "Back" else 1
		var prev_x_changed = false
		for buffer in diag_kick_frames:
			if buffer["left_released"] or buffer["right_released"]:
				dropkick_velocity.y = -1 if buffer["left_released"] else 1
				prev_x_changed = true
				break
		if not x_changed and not prev_x_changed:
			dropkick_velocity.x = 0
	
	var left_released = Input.is_action_just_released("left_"+controller_num)
	var right_released = Input.is_action_just_released("right_"+controller_num)
	var up_released = Input.is_action_just_released("up_"+controller_num)
	var down_released = Input.is_action_just_released("down_"+controller_num)
	diag_kick_frames.push_front({
		"left_released": left_released,
		"right_released": right_released,
		"up_released": up_released,
		"down_released": down_released,
	})
	if diag_kick_frames.size() > diag_kick_buffer:
		diag_kick_frames.resize(diag_kick_buffer)
	
	if Input.is_action_just_released("interact_"+controller_num):
		if !holding_potion and nearby_potions.size() > 0:
			holding_potion = nearby_potions.pop_back()
			holding_potion.get_held(self)
			for p_ray in $PotionRays.get_children():
				p_ray.add_exception(holding_potion)
			g.load_hold_assets(self, number)
			# if picking up a potion ensure dropkick potion ref is reset
			dropkick_potion == null
		elif holding_potion and weakref(holding_potion).get_ref():
			holding_potion.get_thrown()
			holding_potion = null
			g.load_normal_assets(self, number)
			anim_player.play("Throw"+y_facing+x_facing)
			g.play_sfx(self, 'potion_throw')
	
	for p_ray in $PotionRays.get_children():
		p_ray.force_raycast_update()
	if $PotionRays/Left.is_colliding() and Input.is_action_pressed("left_"+controller_num):
		var collider = $PotionRays/Left.get_collider()
		kicking_impulse = Vector2(KICK_FORCE * -1, 0)
		kicking_potion = collider
	elif $PotionRays/UpperLeft.is_colliding() and (Input.is_action_pressed("up_"+controller_num) or Input.is_action_pressed("left_"+controller_num)):
		var collider = $PotionRays/UpperLeft.get_collider()
		kicking_impulse = Vector2(DIAG_KICK_FORCE * -1, DIAG_KICK_FORCE * -1)
		kicking_potion = collider
	elif $PotionRays/Up.is_colliding() and Input.is_action_pressed("up_"+controller_num):
		var collider = $PotionRays/Up.get_collider()
		kicking_impulse = Vector2(0, KICK_FORCE * -1)
		kicking_potion = collider
	elif $PotionRays/UpperRight.is_colliding() and (Input.is_action_pressed("up_"+controller_num) or Input.is_action_pressed("right_"+controller_num)):
		var collider = $PotionRays/UpperRight.get_collider()
		kicking_impulse = Vector2(DIAG_KICK_FORCE, DIAG_KICK_FORCE * -1)
		kicking_potion = collider
	elif $PotionRays/Right.is_colliding() and Input.is_action_pressed("right_"+controller_num):
		var collider = $PotionRays/Right.get_collider()
		kicking_impulse = Vector2(KICK_FORCE, 0)
		kicking_potion = collider
	elif $PotionRays/LowerRight.is_colliding() and (Input.is_action_pressed("down_"+controller_num) or Input.is_action_pressed("right_"+controller_num)):
		var collider = $PotionRays/LowerRight.get_collider()
		kicking_impulse = Vector2(DIAG_KICK_FORCE, DIAG_KICK_FORCE)
		kicking_potion = collider
	elif $PotionRays/Down.is_colliding() and Input.is_action_pressed("down_"+controller_num):
		var collider = $PotionRays/Down.get_collider()
		kicking_impulse = Vector2(0, KICK_FORCE)
		kicking_potion = collider
	elif $PotionRays/LowerLeft.is_colliding() and (Input.is_action_pressed("down_"+controller_num) or Input.is_action_pressed("left_"+controller_num)):
		var collider = $PotionRays/LowerLeft.get_collider()
		kicking_impulse = Vector2(DIAG_KICK_FORCE * -1, DIAG_KICK_FORCE)
		kicking_potion = collider
	elif dropkick_potion != null and weakref(dropkick_potion).get_ref() and \
	((Input.is_action_just_pressed("place_"+controller_num) and "Basic" in dropkick_potion.name) \
	or (Input.is_action_just_pressed("mix_"+controller_num) and not "Basic" in dropkick_potion.name)):
		kicking_potion = dropkick_potion
		dropkick_potion = null
		if dropkick_velocity.x != 0 and dropkick_velocity.y != 0:
			kicking_impulse = Vector2(DIAG_KICK_FORCE * dropkick_velocity.x, DIAG_KICK_FORCE * dropkick_velocity.y)
		else:
			kicking_impulse = Vector2(KICK_FORCE * dropkick_velocity.x, KICK_FORCE * dropkick_velocity.y)
	elif not "Kick" in anim_player.current_animation:
		kicking_impulse = Vector2.ZERO
	
	sprite_animation()
	
	if Input.is_action_just_released("place_"+controller_num) and dropkick_potion == null:
		place_potion()
	elif Input.is_action_just_released("mix_"+controller_num) and dropkick_potion == null:
		place_potion(true)


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
	
	if new_animation == "Run":
		dropkick_potion = null
	
	if new_facing != facing or new_animation != animation:
		var same_anim = animation == new_animation
		var old_anim_time = anim_player.current_animation_position
		animation = new_animation
		facing = new_facing
		anim_player.play(animation + facing)
		if same_anim and anim_player.current_animation_length >= old_anim_time:
			anim_player.advance(old_anim_time)
	
	if new_cardinal_facing != cardinal_facing and not $IceRay.is_colliding():
		cardinal_facing = new_cardinal_facing


func _physics_process(_delta):
	move_and_slide(velocity)
	if disabled or super_disabled or dead_disabled or frozen or "Kick" in anim_player.current_animation:
		velocity = Vector2.ZERO
		return
	get_input()
