extends 'res://potions/potion.gd'

const spikes = preload('res://potions/ice_earth/spikes/spikes.tscn')

func _ready():
	activate()

func _on_ExplodeTimer_timeout():
	explode()

func trigger_effect():		
	$ExplosionArea/Explode.visible = true
	$ExplosionArea/Explode.play()

func _on_Explode_animation_finished():
	var spikes_instance = spikes.instance()
	spikes_instance.global_position = global_position
	spikes_instance
	spikes_instance.last_wiz = last_wiz
	get_parent().add_child(spikes_instance)
	queue_free()
