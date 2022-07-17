extends Node2D

export (int) var speed = 100

var last_wiz
var use_portal = false

func _ready():
	if not use_portal:
		g.play_sfx(self, 'ground_spikes')
	$Particles2D.emitting = true

func _on_Spikes_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area and 'Breakable' in area.get_parent().name:
		area.get_parent().break()


func _on_Spikes_body_entered(body):
	if 'Wizard' in body.name or 'Bot' in body.name:
		body.take_dmg(1, self)


func _on_SelfDestructTimer_timeout():
	queue_free()
	#pass
