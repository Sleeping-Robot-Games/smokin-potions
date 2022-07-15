extends 'res://potions/potion.gd'


var nearby_players = []
var nearby_breakables = []

func _ready():
	$ExplosionArea.connect('area_shape_entered', self, '_on_ExplosionArea_area_shape_entered')
	$ExplosionArea.connect('area_shape_exited', self, '_on_ExplosionArea_area_shape_exited')
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
	print(nearby_players)
	for player in nearby_players:
		print('player damanged')
		print(player.number)
		player.take_dmg(1)
	# destroy all breakables
	for breakable in nearby_breakables:
		breakable.break()
		
	$ExplosionArea/Explode.visible = true
	$ExplosionArea/Explode.play()
	if not use_portal:
		$AudioStreamPlayer.play()

func _on_Explode_animation_finished():
	queue_free()

func _on_ExplosionArea_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area and 'Breakable' in area.get_parent().name:
		nearby_breakables.append(area.get_parent())

func _on_ExplosionArea_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if area and 'Breakable' in area.get_parent().name:
		nearby_breakables.erase(area.get_parent())

func _on_ExplosionArea_body_entered(body):
	if 'Wizard' in body.name or 'Bot' in body.name:
		nearby_players.append(body)
		
func _on_ExplosionArea_body_exited(body):
	if 'Wizard' in body.name or 'Bot' in body.name:
		nearby_players.erase(body)
