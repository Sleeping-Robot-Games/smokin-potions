extends 'res://potions/potion.gd'

const laser_beam = preload('res://potions/ice_arcane/laser_beam/laser_beam.tscn')


func _ready():
	activate()


func _on_ExplodeTimer_timeout():
	explode()


func trigger_effect():
	$ExplosionArea/Explode.visible = true
	$ExplosionArea/Explode.play()
	var laser_beam_instance = laser_beam.instance()
	laser_beam_instance.global_position = Vector2(
		global_position.x,
		global_position.y - laser_beam_instance.max_length
	)
	laser_beam_instance.last_wiz = last_wiz
	laser_beam_instance.use_portal = use_portal
	get_parent().add_child(laser_beam_instance)


func _on_Explode_animation_finished():
	queue_free()
