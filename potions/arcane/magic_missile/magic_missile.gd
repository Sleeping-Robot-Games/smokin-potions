extends Node2D


export (int) var speed = 100

func _physics_process(delta):
	if not get_node("VisibilityNotifier2D").is_on_screen():
		cleanup()
	position += transform.x * speed * delta


func cleanup():
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	cleanup()


func _on_MagicMissile_body_entered(body):
	if 'Wizard' in body.name:
		print('kill the wizard')
		print(body)


func _on_MagicMissile_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area and 'Breakable' in area.get_parent().name:
		area.get_parent().break()
		cleanup()