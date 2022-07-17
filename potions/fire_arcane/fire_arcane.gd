extends 'res://potions/potion.gd'

const lightning = preload('res://potions/fire_arcane/lightning/lightning.tscn')

var nearby_players = []
var nearby_breakables = []

func _ready():
#	$ExplosionArea.connect('area_shape_entered', self, '_on_ExplosionArea_area_shape_entered')
#	$ExplosionArea.connect('area_shape_exited', self, '_on_ExplosionArea_area_shape_exited')
#	$ExplosionArea.connect('body_entered', self, '_on_ExplosionArea_body_entered')
#	$ExplosionArea.connect('body_exited', self, '_on_ExplosionArea_body_exited')
	activate()


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
	#if not use_portal:
	#	$AudioStreamPlayer.play()


func _on_Explode_animation_finished():
	
	
	rng.randomize()
	for i in rng.randi_range(2, 5):
		var lightning_instance = lightning.instance()
		lightning_instance.global_position = global_position
		lightning_instance.last_wiz = last_wiz
		lightning_instance.use_portal = use_portal
		get_parent().add_child(lightning_instance)
		rng.randomize()
		lightning_instance.rotation_degrees = rng.randi_range(0, 360)
		rng.randomize()
#	if nearby_players.size() > 0:
#		var i = rng.randi_range(0, nearby_players.size() - 1)
#		lightning_instance.look_at(nearby_players[i].global_position)
#	elif nearby_breakables.size() > 0:
#		var i = rng.randi_range(0, nearby_breakables.size() - 1)
#		lightning_instance.look_at(nearby_breakables[i].global_position)
#	else:
#		lightning_instance.rotation_degrees = rng.randi_range(0, 360)
	queue_free()


#func _on_ExplosionArea_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
#	if g.is_breakable(area):
#		nearby_breakables.append(area.get_parent())
#
#func _on_ExplosionArea_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
#	if g.is_breakable(area):
#		nearby_breakables.erase(area.get_parent())
#
#func _on_ExplosionArea_body_entered(body):
#	if g.is_player(body):
#		nearby_players.append(body)
#
#func _on_ExplosionArea_body_exited(body):
#	if g.is_player(body):
#		nearby_players.erase(body)
