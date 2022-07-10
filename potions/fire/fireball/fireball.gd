extends Node2D

export (int) var speed = 750


func _physics_process(delta):
	if not get_node("VisibilityNotifier2D").is_on_screen():
		cleanup()
	position += transform.x * speed * delta

func _on_VisibilityNotifier2D_screen_exited():
	cleanup()

func cleanup():
	queue_free()

func _on_Fireball_body_entered(body):
	if 'Wizard' in body.name:
		print('kill the wizard')
		print(body)
