extends RigidBody2D

var use_portal = false
var original_potion

func _ready():
	if use_portal:
		$Portal.visible = true
		$AnimationPlayer.play('fade')

func but_make_it_symmetrical(elements):
	# Generate potion instances
	var symmetrical_potions = []
	for i in range(3):
		var symmetrical_potion = g.get_potion_scene(elements).instance()
		symmetrical_potion.add_to_group(str(get_instance_id()))
		
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


func explode():
	$AnimatedSprite.play()
	# EXPLODE


func _on_ExplodeTimer_timeout():
	explode()
	
func trigger_effect():
	pass # Used in children


func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.visible = false
	# prevents the potion from moving while the explode animation plays
	mode = MODE_STATIC 
	# lets players move through the explosion
	$CollisionShape2D.disabled = true
	trigger_effect()
