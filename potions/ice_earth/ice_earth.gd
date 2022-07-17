extends 'res://potions/potion.gd'


var nearby_players = []

func _ready():
	$ExplosionArea.connect('body_entered', self, '_on_ExplosionArea_body_entered')
	$ExplosionArea.connect('body_exited', self, '_on_ExplosionArea_body_exited')
	activate()


func activate():
	$ExplodeTimer.start()

func explode():
	$AnimatedSprite.play()
	# EXPLODE

func _on_ExplodeTimer_timeout():
	explode()


func trigger_effect():
	for player in nearby_players:
		player.freeze();
	
	$ExplosionArea/Explode.visible = true
	$ExplosionArea/Explode.play()
#	if not use_portal:
#		$AudioStreamPlayer.play()

func _on_Explode_animation_finished():
	queue_free()

func _on_ExplosionArea_body_entered(body):
	if body and weakref(body).get_ref() and 'Wizard' in body.name or 'Bot' in body.name:
		nearby_players.append(body)
		
func _on_ExplosionArea_body_exited(body):
	if body and weakref(body).get_ref() and 'Wizard' in body.name or 'Bot' in body.name:
		nearby_players.erase(body)
