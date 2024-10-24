extends Node2D

export (int) var speed = 110
export (int) var force = 2

var nearby_players = []
var nearby_potions = []
var use_portal = false

func _ready():
	if not use_portal:
		g.play_sfx(self, 'black_hole')


func _physics_process(_delta):
	for c in nearby_players:
		var velocity = c.global_position.direction_to(global_position)
		velocity = velocity.normalized() * speed
		c.move_and_slide(velocity)
	
	for c in nearby_potions:
		if c.bombs_away:
			return
		var velocity = c.global_position.direction_to(global_position)
		velocity = velocity.normalized() * force
#		velocity = Vector2(velocity.x * -1, velocity.y * -1)
		c.apply_central_impulse(velocity)
		#c.move_and_slide(velocity)


func _on_SelfDestructTimer_timeout():
	queue_free()


func _on_Area2D_body_entered(body):
	if g.is_player(body):
		nearby_players.append(body)


func _on_Area2D_body_exited(body):
	if g.is_player(body):
		nearby_players.erase(body)


func _on_Area2D_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if g.is_potion_area(area):
		#area.get_parent().mode = area.get_parent().MODE_KINEMATIC
		nearby_potions.append(area.get_parent())


func _on_Area2D_area_shape_exited(_area_rid, area, _area_shape_index, _local_shape_index):
	if g.is_potion_area(area):
		nearby_potions.erase(area.get_parent())
