extends Node2D

var last_wiz
var chained = false

func _ready():
	$electricity.emitting = true
	$Area2D.connect('area_shape_entered', self, '_on_area_shape_entered')
	$Area2D.connect('body_entered', self, '_on_body_entered')


func chain_lightning(next_target, type):
	chained = true
	var lightning_instance = load('res://potions/fire_arcane/lightning/lightning.tscn').instance()
	lightning_instance.global_position = global_position
	lightning_instance.last_wiz = last_wiz
	get_parent().add_child(lightning_instance)
	lightning_instance.look_at(next_target.global_position)
	if type == "breakable":
		next_target.break()
	elif type == "player":
		next_target.take_dmg(1, self)


func _on_MagicMissile_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area and 'Breakable' in area.get_parent().name:
		area.get_parent().break()
		queue_free()


func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if not chained and area and weakref(area).get_ref() and 'Breakable' in area.get_parent().name:
		chain_lightning(area.get_parent(), 'breakable')


func _on_body_entered(body):
	if not chained and body and weakref(body).get_ref() and 'Wizard' in body.name or 'Bot' in body.name:
		chain_lightning(body, 'player')


func _on_SelfDestructTimer_timeout():
	queue_free()
