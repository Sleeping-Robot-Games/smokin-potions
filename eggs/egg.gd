extends Node2D

export (int) var heat_needed = 100

var player_names = ["Rogue"]
var nearby_players = 0


func _ready():
	$TextureProgress.max_value = heat_needed


func hatch():
	$AnimatedSprite.play()
	$TextureProgress.visible = false
	# spawn power up / monster?


func _on_Timer_timeout():
	$TextureProgress.value += nearby_players
	if $TextureProgress.value >= $TextureProgress.max_value:
		hatch()


func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.visible = false


func _on_Egg_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if player_names.has(body.name):
		nearby_players += 1
		$AnimatedSprite.modulate = Color(1, 0.5, 0.5, 1)


func _on_Egg_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if player_names.has(body.name) and nearby_players > 0:
		nearby_players -= 1
		if nearby_players == 0:
			$AnimatedSprite.modulate = Color(1, 1, 1, 1)
