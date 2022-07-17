extends Node2D

export (int) var speed = 100

var last_wiz
var nearby_players = []
var timers = []
var use_portal = false


func _ready():
	if not use_portal:
		g.play_sfx(self, 'lava_happening')
#	$Area2D.connect('area_shape_entered', self, '_on_area_shape_entered')
	$Area2D.connect('body_entered', self, '_on_body_entered')
	$Area2D.connect('body_exited', self, '_on_body_exited')


#func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
#	if area and weakref(area).get_ref() and ('Breakable' in area.get_parent().name or 'Durable' in area.get_parent().name or 'Boundaries' in area.get_parent().name or 'NoLavaOrIce' in area.get_parent().name):
#		queue_free()


func _on_body_entered(body):
	if body and weakref(body).get_ref() and 'Wizard' in body.name or 'Bot' in body.name:
		nearby_players.append(body)
		body.take_dmg(1, self)
		var timer = Timer.new()
		timer.wait_time = 1.5
		timer.one_shot = true
		timer.autostart = true
		timer.connect('timeout', self, '_on_timer_timeout', [body])
		timers.append({"timer": timer, "player": body})
		add_child(timer)


func _on_timer_timeout(body):
	if body and weakref(body).get_ref() and nearby_players.has(body):
		body.take_dmg(1, self)


func _on_body_exited(body):
	if body and weakref(body).get_ref() and 'Wizard' in body.name or 'Bot' in body.name:
		nearby_players.erase(body)
		for t in timers:
			if t["player"] == body:
				t["timer"].queue_free()
				timers.erase(t)


func _on_SelfDestructTimer_timeout():
	queue_free()
