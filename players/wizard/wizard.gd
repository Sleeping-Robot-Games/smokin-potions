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
	if x_changed:
		dropkick_velocity.x = -1 if x_facing == "Left" else 1
		if not y_changed:
			# TODO: account for x frame buffer when letting of 2 dirs at once (aka moving diag) will still register that as last moving diagonally
			dropkick_velocity.y = 0
	if y_changed:
		dropkick_velocity.y = -1 if y_facing == "Back" else 1
		if not x_changed:
			# TODO: here too
			dropkick_velocity.x = 0
	
	if Input.is_action_just_released("interact_"+controller_num):
		if !holding_potion and nearby_potions.size() > 0:
			holding_potion = nearby_potions.pop_back()
			holding_potion.get_held(self)
			for p_ray in $PotionRays.get_children():
				p_ray.add_exception(holding_potion)
			g.load_hold_assets(self, number)
		elif holding_potion and weakref(holding_potion).get_ref():
			holding_potion.get_thrown()
			holding_potion = null
			g.load_normal_assets(self, number)
			anim_player.play("Throw"+y_facing+x_facing)
			g.play_sfx(self, 'potion_throw')
		
	var is_dropkicking = false
	if Input.is_action_just_pressed("place_"+controller_num):
		print('-------------')
		print('place pressed...')
		print('dropkick_potion != null: ' + str(dropkick_potion != null))
		print('weakref(dropkick_potion).get_ref(): ' + str(weakref(dropkick_potion).get_ref()))
		print('-------------')
	
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
	elif dropkick_potion != null and weakref(dropkick_potion).get_ref() and Input.is_action_just_pressed("place_"+controller_num):
		is_dropkicking = true
		kicking_potion = dropkick_potion
		dropkick_potion = null
		if dropkick_velocity.x != 0 and dropkick_velocity.y != 0:
			kicking_impulse = Vector2(DIAG_KICK_FORCE * dropkick_velocity.x, DIAG_KICK_FORCE * dropkick_velocity.y)
		else:
			kicking_impulse = Vector2(KICK_FORCE * dropkick_velocity.x, KICK_FORCE * dropkick_velocity.y)
		print('dropkicking: ' + kicking_potion.name)
		print('kicking_impulse: ' + str(kicking_impulse))
	elif not is_kicking:
		kicking_impulse = Vector2.ZERO
	
	sprite_animation()
	
	if Input.is_action_just_released("place_"+controller_num) and not is_dropkicking:
		place_potion()
	elif Input.is_action_just_released("mix_"+controller_num):
		place_potion(true)


func sprite_animation():
	new_facing = y_facing + x_facing
	if x_changed:
		new_cardinal_facing = x_facing
	elif y_changed:
		new_cardinal_facing = y_facing
	
	var new_animation = animation
	if kicking_impulse != Vector2.ZERO:
		is_kicking = true
		velocity = Vector2.ZERO
		new_animation = "Kick"
		print('kicking')
	elif velocity == Vector2(0,0) and !is_kicking:
		new_animation = "Idle"
	elif velocity != Vector2(0,0) and !is_kicking:
		new_animation = "Run"
	
	if not movement_enabled and new_animation == "Run":
		new_animation = "Idle"
	
	if new_animation == "Run":
		dropkick_potion = null
	
	if new_facing != facing or new_animation != animation:
		facing = new_facing
		animation = new_animation
		print('playing: ' + animation + facing)
		anim_player.play(animation + facing)
	
	if new_cardinal_facing != cardinal_facing and not $IceRay.is_colliding():
		cardinal_facing = new_cardinal_facing


func _physics_process(_delta):
	move_and_slide(velocity)
	if disabled or super_disabled or dead_disabled or frozen or "Kick" in anim_player.current_animation:
		velocity = Vector2.ZERO
		return
	get_input()
