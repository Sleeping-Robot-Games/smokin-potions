extends 'res://potions/potion.gd'

const fireball = preload('res://potions/fire/fireball/fireball.tscn')

var fx_rotation = 0

var clockwise = ['UpperLeft', 'UpperRight', 'LowerRight', 'LowerLeft']
var fx_dict = {
	'UpperLeft': 0,
	'UpperRight': 90,
	'LowerRight': 180,
	'LowerLeft': 270
}
var orginal_quadrant

func _ready():
	orginal_quadrant = get_quadrant()
	activate()

func trigger_effect():
	var fireball_instance = fireball.instance()
	fireball_instance.global_position = global_position
	get_parent().add_child(fireball_instance)
	fireball_instance.rotation_degrees = fx_dict[orginal_quadrant]
	queue_free()
