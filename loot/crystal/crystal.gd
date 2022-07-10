extends Node2D


var rng = RandomNumberGenerator.new()
var element = 'fire'


func _ready():
	rng.randomize()
	var type = rng.randi_range(0, 3)
	if type == 0:
		element = 'fire'
	elif type == 1:
		element = "ice"
	elif type == 2:
		element = "earth"
	elif type == 3:
		element = "arcane"
	$Sprite.set_texture(load("res://loot/crystal/" + element + ".png"))


func cleanup():
	queue_free();
