extends 'res://potions/potion.gd'

var rng = RandomNumberGenerator.new()
const magic_missile = preload('res://potions/arcane/magic_missile/magic_missile.tscn')

func _ready():
	activate()

func _on_ExplodeTimer_timeout():
	explode()

func trigger_effect():		
	$ExplosionArea/Explode.visible = true
	$ExplosionArea/Explode.play()

func _on_Explode_animation_finished():
	for i in range(3):
		var magic_missile_instance = magic_missile.instance()
		magic_missile_instance.global_position = global_position
		get_parent().add_child(magic_missile_instance)
		rng.randomize()
		magic_missile_instance.rotation_degrees = rng.randi_range(0, 360)
	queue_free()

