extends RigidBody2D

var use_portal = false
var original_potion
var kick_impulse = Vector2.ZERO
var last_position = Vector2.ZERO
var is_moving = false
var holder: KinematicBody2D
var parent_player = null
var potion_daddy

func _ready():
	connect('body_entered', self, '_on_body_entered')
	
	if use_portal:
		$Portal.visible = true
		$AnimationPlayer.play('fade')
	else:
		# when player first places potion, disable collision
		$SpawningPlayerArea.connect('body_exited', self, '_on_body_exited')
		add_collision_exception_with(parent_player)
		for c in parent_player.get_children():
			if c is RayCast2D:
				c.add_exception(self)


func _on_body_exited(body):
	# when player leaves potion area, re-enable collision
	if body == parent_player:
		remove_collision_exception_with(parent_player)
		for c in parent_player.get_children():
			if c is RayCast2D:
				c.remove_exception(self)


func but_make_it_symmetrical(elements):
	# Generate potion instances
	var symmetrical_potions = []
	for i in range(3):
		var symmetrical_potion = g.get_potion_scene(elements).instance()
		# symmetrical_potion.add_to_group(str(get_instance_id()))
		symmetrical_potion.but_symmetrical(self)
		symmetrical_potions.append(symmetrical_potion)
	
	var potion_positions = []
	potion_positions.append(Vector2(global_position.x, get_viewport_rect().size.y - global_position.y))
	potion_positions.append(Vector2(get_viewport_rect().size.x - global_position.x, global_position.y))
	potion_positions.append(Vector2(get_viewport_rect().size.x - global_position.x, get_viewport_rect().size.y - global_position.y))
	
	# Assign potion positions and lay them
	for i in range(symmetrical_potions.size()):
		symmetrical_potions[i].global_position = potion_positions[i]
		get_parent().add_child(symmetrical_potions[i])


func but_symmetrical(_original_potion):
	use_portal = true
	original_potion = _original_potion


func activate():
	$ExplodeTimer.start()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'fade':
		$Portal.visible = false
	if 'Throw' in anim_name:
		if holder.cardinal_facing == 'front':
			z_index = 1
		var true_global = global_position
		g.reparent(self, get_parent().get_parent()) 
		global_position = true_global
		for c in holder.get_children():
			if c is RayCast2D:
				c.remove_exception(self)
		holder = null
		potion_daddy.queue_free()
		potion_daddy = null


func explode():
	$AnimatedSprite.play()
	# EXPLODE


func _on_ExplodeTimer_timeout():
	explode()


func trigger_effect():
	pass # Used in children


func kick(impulse):
	kick_impulse = impulse 
	apply_central_impulse(impulse)


func get_held(player):
	holder = player
	sleeping = true
	add_collision_exception_with(holder)
	potion_daddy = Position2D.new()
	potion_daddy.name = 'daddy'
	holder.add_child(potion_daddy)
	g.reparent(self, potion_daddy)


func get_thrown():
	var true_pos = global_position
	g.reparent(potion_daddy, get_node('/root/Game/YSort'))
	potion_daddy.global_position = true_pos
	position = Vector2.ZERO
	remove_collision_exception_with(holder)
	$AnimationPlayer.play("Throw"+holder.cardinal_facing)
	if holder.cardinal_facing == 'Front':
		z_index = 2
	

func _on_body_entered(body):
	if "Potion" in body.name and is_moving and kick_impulse != Vector2.ZERO:
		body.kick(kick_impulse)
		kick_impulse = Vector2.ZERO
		sleeping = true


func _physics_process(delta):
	if holder:
		global_position = Vector2(holder.global_position.x, holder.global_position.y - 20)
	else:
		var cur_position = global_position
		is_moving = cur_position != last_position
		last_position = cur_position


func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.visible = false
	# prevents the potion from moving while the explode animation plays
	mode = MODE_STATIC 
	# lets players move through the explosion
	$CollisionShape2D.disabled = true
	trigger_effect()
	# if the player is still holding the potion reset it's held state
	if holder != null and holder.holding_potion != null:
		g.load_normal_assets(holder, holder.number)
		holder.holding_potion = null
		holder = null


func get_quadrant(potion = self):
	var quadrant = "Upper" if potion.global_position.y <= get_viewport_rect().size.y / 2 else "Lower"
	quadrant += "Left" if potion.global_position.x <= get_viewport_rect().size.x / 2 else "Right"
	return quadrant
