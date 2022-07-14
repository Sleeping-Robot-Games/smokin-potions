extends StaticBody2D

const rune = preload('res://pickups/runes/rune.tscn')
var rng = RandomNumberGenerator.new()

func _ready():
	pass


func break():
	$Crumbling.visible = true
	$Crumbling.play()
	$Sprite.visible = false


func _on_Crumbling_animation_finished():
	rng.randomize()
	var has_loot = rng.randi_range(0, 1)
	if has_loot:
		rng.randomize()
		# Runes, Scrolls, ???
		var loot_type = rng.randi_range(0, 0)
		if loot_type == 0:
			# Spawn a rune
			var rune_instance = rune.instance()
			rune_instance.global_position = global_position
			get_parent().add_child(rune_instance)
	queue_free()
