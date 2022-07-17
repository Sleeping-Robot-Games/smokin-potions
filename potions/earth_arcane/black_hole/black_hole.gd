extends Node2D

export (int) var speed = 75
export (int) var force = 2

var nearby_players = []
var nearby_potions = []
var use_portal = false

func _ready():
	if not use_portal:
		g.play_sfx(self, 'black_hole')


func _physics_process(delta):
	for c in nearby_players:
		var velocity = c.global_position.direction_to(global_position)
		velocity = velocity.normalized() * speed
		c.move_and_slide(velocity)
	
	for c in nearby_potions:
		var velocity = c.global_position.direction_to(global_position)
		velocity = velocity.normalized() * force
#		velocity = Vector2(velocity.x * -1, velocity.y * -1)
		c.apply_central_impulse(velocity)
		#c.move_and_slide(velocity)


func _on_SelfDestructTimer_timeout():
	queue_free()


func _on_Area2D_body_entered(body):
	if body and weakref(body).get_ref() and 'Wizard' in body.name or 'Bot' in body.name:
		nearby_players.append(body)


func _on_Area2D_body_exited(body):
	if body and weakref(body).get_ref() and 'Wizard' in body.name or 'Bot' in body.name:
		nearby_players.erase(body)


func _on_Area2D_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area and weakref(area).get_ref() and 'Potion' in area.get_parent().name:
		#area.get_parent().mode = area.get_parent().MODE_KINEMATIC
		nearby_potions.append(area.get_parent())


func _on_Area2D_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if area and weakref(area).get_ref() and 'Potion' in area.get_parent().name:
		nearby_potions.erase(area.get_parent())
