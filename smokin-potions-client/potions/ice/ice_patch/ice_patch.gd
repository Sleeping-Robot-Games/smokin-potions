extends Node2D

export (int) var speed = 100

var use_portal = false

func _ready():
	if not use_portal:
		g.play_sfx(self, 'ground_freeze')

#func _ready():
#	$Area2D.connect('area_shape_entered', self, '_on_area_shape_entered')
#	$Area2D.connect('body_entered', self, '_on_body_entered')


#func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
#	if area and weakref(area).get_ref() and ('Breakable' in area.get_parent().name or 'Durable' in area.get_parent().name or 'Boundaries' in area.get_parent().name or 'NoLavaOrIce' in area.get_parent().name):
#		queue_free()
#
#
#func _on_body_entered(body):
#	if body and weakref(body).get_ref() and 'Wizard' in body.name or 'Bot' in body.name:
#		pass


func _on_SelfDestructTimer_timeout():
	queue_free()
