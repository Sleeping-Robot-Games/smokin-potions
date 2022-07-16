extends 'res://potions/potion.gd'

const ice_patch = preload('res://potions/ice/ice_patch/ice_patch.tscn')
const size = 3
const cell = 12

func _ready():
	activate()

func _on_ExplodeTimer_timeout():
	explode()

func trigger_effect():
	$ExplosionArea/Explode.visible = true
	$ExplosionArea/Explode.play()
	
	for x in range(size * -1, size):
		for y in range(size * -1, size):
			if (x == size or x == size * -1) and (y == size or y == size * -1):
				continue
			if (x == size - 1 or x == (size * -1) + 1) and (y == size - 1 or y == (size * -1) + 1):
				continue
			var ice_patch_instance = ice_patch.instance()
			ice_patch_instance.global_position = Vector2(
				global_position.x + (x*cell),
				global_position.y + (y*cell)
			)
			get_parent().add_child(ice_patch_instance)

func _on_Explode_animation_finished():
	queue_free()

