extends RigidBody2D

export (int) var heat_needed = 100

var nearby_players = []
var nearby_breakables = []

var use_portal = false


func _ready():
	if use_portal:
		$Portal.visible = true
		$AnimationPlayer.play('fade')

func but_symmetrical():
	use_portal = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'fade':
		$Portal.visible = false


func explode():
	$AnimatedSprite.play()
	# EXPLODE


func _on_ExplodeTimer_timeout():
	explode()


func _on_Area2D_body_entered(body):
	if body.name == 'Wizard':
		nearby_players.append(body)


func _on_Area2D_body_exited(body):
	if body.name == 'Wizard':
		nearby_players.erase(body)

func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.visible = false

func _on_Explode_animation_finished():
	queue_free()


func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.frame == 13:
		# prevents the egg from moving while the explode animation plays
		mode = MODE_STATIC 
		# lets players move through the explosion
		$CollisionShape2D.disabled = true
		# splody all players in area
		for player in nearby_players:
			print(player)
			print('go splody')
		# destroy all breakables
		for breakable in nearby_breakables:
			breakable.break()
			
		$ExplosionArea/Explode.visible = true
		$ExplosionArea/Explode.play()


func _on_ExplosionArea_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area and 'Breakable' in area.get_parent().name:
		nearby_breakables.append(area.get_parent())


func _on_ExplosionArea_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if area and 'Breakable' in area.get_parent().name:
		nearby_breakables.erase(area.get_parent())

