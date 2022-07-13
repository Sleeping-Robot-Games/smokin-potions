extends Node2D

var player

func remove_scent():
  player.scent_trail.erase(self)
  queue_free()


func _on_CleanupTimer_timeout():
	remove_scent()
