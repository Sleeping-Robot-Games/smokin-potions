extends 'res://potions/potion.gd'


var nearby_players = []
var nearby_breakables = []

func _ready():
	activate()


func activate():
	$ExplodeTimer.start()


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

func trigger_effect():
	for player in nearby_players:
		print(player)
		print('go splody')
	# destroy all breakables
	for breakable in nearby_breakables:
		breakable.break()
		
	$ExplosionArea/Explode.visible = true
	$ExplosionArea/Explode.play()

func _on_Explode_animation_finished():
	queue_free()

func _on_ExplosionArea_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area and 'Breakable' in area.get_parent().name:
		nearby_breakables.append(area.get_parent())


func _on_ExplosionArea_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if area and 'Breakable' in area.get_parent().name:
		nearby_breakables.erase(area.get_parent())

