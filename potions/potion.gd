extends RigidBody2D

export (int) var heat_needed = 100

var nearby_players = []


func _ready():
	$AnimatedSprite.modulate = Color(1, 0.5, 0.5, 1)


func hatch():
	$AnimatedSprite.play()
	# EXPLODE


func _on_ExplodeTimer_timeout():
		hatch()


func _on_Egg_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	pass


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
		$Area2D/Explode.visible = true
		$Area2D/Explode.play()
