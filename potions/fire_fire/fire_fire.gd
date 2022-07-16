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
	if use_portal:
		set_explode_timer()
	activate()

func trigger_effect():
	var fireball_instance = fireball.instance()
	fireball_instance.global_position = global_position
	fireball_instance.last_wiz = last_wiz
	fireball_instance.scale = Vector2(2, 2)
	get_parent().add_child(fireball_instance)
	fireball_instance.rotation_degrees = fx_dict[orginal_quadrant]
	queue_free()

func set_explode_timer():
	var starting_quadrant = get_quadrant(original_potion) 
	var starting_quadrant_index = clockwise.find(starting_quadrant)
	var quadrant = get_quadrant()
	var quadrant_index = clockwise.find(quadrant) 
	if quadrant_index < starting_quadrant_index:
		$ExplodeTimer.wait_time = (len(clockwise) - starting_quadrant_index) + (quadrant_index + 1)
	else:
		$ExplodeTimer.wait_time = (quadrant_index - starting_quadrant_index) + 1
