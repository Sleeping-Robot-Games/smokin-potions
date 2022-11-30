extends 'res://potions/potion.gd'
# warning-ignore-all:return_value_discarded


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
	for player in nearby_players:
		player.take_dmg(1, self)
	# destroy all breakables
	for breakable in nearby_breakables:
		breakable.break()
		
	$ExplosionArea/Explode.visible = true
	$ExplosionArea/Explode.play()
	if not use_portal:
		$AudioStreamPlayer.play()


func _on_Explode_animation_finished():
	queue_free()


func _on_ExplosionArea_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if g.is_breakable(area):
		nearby_breakables.append(area.get_parent())


func _on_ExplosionArea_area_shape_exited(_area_rid, area, _area_shape_index, _local_shape_index):
	if g.is_breakable(area):
		nearby_breakables.erase(area.get_parent())


func _on_ExplosionArea_body_entered(body):
	if g.is_player(body):
		nearby_players.append(body)


func _on_ExplosionArea_body_exited(body):
	if g.is_player(body):
		nearby_players.erase(body)
