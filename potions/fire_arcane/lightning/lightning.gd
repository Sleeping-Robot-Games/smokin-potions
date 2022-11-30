extends Node2D
# warning-ignore-all:return_value_discarded

var rng = RandomNumberGenerator.new()

var last_wiz
var chained = false
var use_portal = false

func _ready():
	$electricity.emitting = true
	$Area2D.connect('area_shape_entered', self, '_on_area_shape_entered')
	$Area2D.connect('body_entered', self, '_on_body_entered')
	if not use_portal:
		rng.randomize()
		var sfx_num = rng.randi_range(1, 3)
		g.play_sfx(self, 'electricity_' + str(sfx_num))


#func chain_lightning(next_target, type):
#	chained = true
#	var lightning_instance = load('res://potions/fire_arcane/lightning/lightning.tscn').instance()
#	lightning_instance.global_position = global_position
#	lightning_instance.last_wiz = last_wiz
#	get_parent().add_child(lightning_instance)
#	lightning_instance.look_at(next_target.global_position)
#	if type == "breakable":
#		next_target.break()
#	elif type == "player":
#		next_target.take_dmg(1, self)


func _on_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
#	if not chained and area and weakref(area).get_ref() and 'Breakable' in area.get_parent().name:
#		chain_lightning(area.get_parent(), 'breakable')
	if g.is_breakable(area):
		area.get_parent().break()


func _on_body_entered(body):
#	if not chained and body and weakref(body).get_ref() and 'Wizard' in body.name or 'Bot' in body.name:
#		chain_lightning(body, 'player')
	if g.is_player(body):
		body.take_dmg(1, self)

func _on_SelfDestructTimer_timeout():
	queue_free()
