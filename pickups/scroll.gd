extends Node2D


var rng = RandomNumberGenerator.new()
var magic = 'humungo'
var label_text = 'Humungo!'


func _ready():
	$AnimationPlayer.play('float')
	
	rng.randomize()
	var type = rng.randi_range(0, 4)
	if type == 0:
		magic = 'humungo'
		label_text = 'Humungo!'
	elif type == 1:
		magic = "tinyboi"
		label_text = "Tiny!"
	elif type == 2:
		magic = 'potionparty'
		label_text = "Potion Party!"
	elif type == 3:
		magic = 'heal'
		label_text = "Healing!"
	elif type == 4:
		magic = 'symmetry'
		label_text = "Symmetrical Potions!"

	if magic == 'heal':
		$Sprite.set_texture(load('res://pickups/heart.png'))

func cleanup():
	queue_free();


func _on_DespawnTimer_timeout():
	$AnimationPlayer.play("despawn")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "despawn":
		cleanup()
