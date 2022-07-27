extends Node


func _ready():
	if g.new_game:
		$Splashscreen.visible = true
		var music_player = $AudioStreamPlayer
		music_player.stream = load('res://sfx/title_screen.mp3')
		music_player.play()
		$Timer.start()
	else:
		$Splashscreen.visible = false


func _on_Timer_timeout():
	$Splashscreen.visible = false
	$Title.visible = true
