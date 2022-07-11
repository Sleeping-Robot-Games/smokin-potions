extends 'res://potions/potion.gd'

var rng = RandomNumberGenerator.new()
const laser_beam = preload('res://potions/arcane_arcane/laser_beam/laser_beam.tscn')

func _ready():
	activate()

func _on_ExplodeTimer_timeout():
	explode()

func trigger_effect():		
	$ExplosionArea/Explode.visible = true
	$ExplosionArea/Explode.play()

func _on_Explode_animation_finished():
	var laser_beam_instance = laser_beam.instance()
	laser_beam_instance.target_coords = global_position
	laser_beam_instance.global_position = Vector2(global_position.x, global_position.y - laser_beam_instance.max_length)
	get_parent().add_child(laser_beam_instance)
	queue_free()

