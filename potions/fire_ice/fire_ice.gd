extends 'res://potions/potion.gd'

const smoke = preload('res://potions/fire_ice/smoke/smoke.tscn')

func _ready():
	activate()

func _on_ExplodeTimer_timeout():
	explode()

func trigger_effect():		
	$ExplosionArea/Explode.visible = true
	$ExplosionArea/Explode.play()
	var smoke_instance = smoke.instance()
	smoke_instance.global_position = global_position
	get_node("/root/Game").add_child(smoke_instance)

func _on_Explode_animation_finished():
	queue_free()

