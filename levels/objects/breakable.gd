extends StaticBody2D

const crystal = preload('res://loot/crystal/crystal.tscn')
var rng = RandomNumberGenerator.new()

func _ready():
	pass


func break():
	rng.randomize()
	var has_loot = rng.randi_range(0, 1)
	if has_loot:
		rng.randomize()
		# Crystals, Scrolls, ???
		var loot_type = rng.randi_range(0, 0)
		if loot_type == 0:
			# Spawn a crystal
			var crystal_instance = crystal.instance()
			crystal_instance.global_position = global_position
			get_parent().add_child(crystal_instance)
	queue_free()
