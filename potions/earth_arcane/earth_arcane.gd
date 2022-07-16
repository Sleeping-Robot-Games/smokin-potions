extends 'res://potions/potion.gd'

const black_hole = preload('res://potions/earth_arcane/black_hole/black_hole.tscn')

func _ready():
	activate()

func _on_ExplodeTimer_timeout():
	explode()

func trigger_effect():		
	$ExplosionArea/Explode.visible = true
	$ExplosionArea/Explode.play()

func _on_Explode_animation_finished():
	var black_hole_instance = black_hole.instance()
	black_hole_instance.global_position = global_position
	black_hole_instance
	get_parent().add_child(black_hole_instance)
	queue_free()

