extends Node2D

export (int) var speed = 100

var last_wiz
var use_portal = false

func _ready():
	if not use_portal:
		g.play_random_sfx(self, 'magic_missiles', 3)

func _physics_process(delta):
	if not get_node("VisibilityNotifier2D").is_on_screen():
		cleanup()
	position += transform.x * speed * delta


func cleanup():
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	cleanup()


func _on_MagicMissile_body_entered(body):
	if g.is_player(body):
		body.take_dmg(1)


func _on_MagicMissile_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if g.is_breakable(area):
		area.get_parent().break()
		cleanup()
