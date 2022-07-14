extends StaticBody2D

const rune = preload('res://pickups/runes/rune.tscn')
var rng = RandomNumberGenerator.new()
var sprite = "001"

func _ready():
	rng.randomize()
	var sprite_num = rng.randi_range(1, 6)
	sprite = str(sprite_num).pad_zeros(3)
	$Sprite.set_texture(load("res://levels/objects/Rock_" + sprite + ".png"))


func break():
	$Sprite.set_texture(load("res://levels/objects/Rockbroken_" + sprite + ".png"))
	$AnimationPlayer.play("fade")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade":
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
