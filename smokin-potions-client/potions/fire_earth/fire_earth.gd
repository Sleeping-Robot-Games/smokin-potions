extends 'res://potions/potion.gd'

const lava = preload('res://potions/fire_earth/lava/lava.tscn')
#const size = 3
#const cell = 12

func _ready():
	activate()

func _on_ExplodeTimer_timeout():
	explode()

func trigger_effect():
	$ExplosionArea/Explode.visible = true
	$ExplosionArea/Explode.play()
	
	var lava_instance = lava.instance()
	lava_instance.global_position = global_position
	lava_instance.use_portal = use_portal
	lava_instance.scale = Vector2(2, 2)
	get_parent().add_child(lava_instance)
	
#	for x in range(size * -1, size):
#		for y in range(size * -1, size):
#			if (x == size or x == size * -1) and (y == size or y == size * -1):
#				continue
#			if (x == size - 1 or x == (size * -1) + 1) and (y == size - 1 or y == (size * -1) + 1):
#				continue
#			var lava_instance = lava.instance()
#			lava_instance.global_position = Vector2(
#				global_position.x + (x*cell),
#				global_position.y + (y*cell)
#			)
#			lava_instance.last_wiz = last_wiz
#			get_parent().add_child(lava_instance)

func _on_Explode_animation_finished():
	queue_free()

