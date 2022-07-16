extends Node2D


var rng = RandomNumberGenerator.new()
var element = 'fire'


func _ready():
	$AnimationPlayer.play('float')
	
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
	$Sprite.set_texture(load("res://pickups/runes/" + element + ".png"))

func set_type(type):
	$Sprite.set_texture(load("res://pickups/runes/" + type + ".png"))
	element = type

func cleanup():
	queue_free();


func _on_DespawnTimer_timeout():
	$AnimationPlayer.play("despawn")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "despawn":
		queue_free()
