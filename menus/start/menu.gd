extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if g.new_game:
		$Splashscreen.visible = true
		var music_player = $AudioStreamPlayer
		music_player.stream = load('res://sfx/title_screen.mp3')
		music_player.play()
		$Timer.start()
	else:
		$Splashscreen.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	$Splashscreen.visible = false
	$Title.visible = true
