extends Node2D


func _ready():
	$Particles2D.emitting = true
	g.play_random_sfx(self, 'smoke_proof', 4)

func _on_SelfDestructTimer_timeout():
	queue_free()
