extends Node

var title_scene = preload("res://menus/start/Title.tscn")
var selection_scene = preload("res://menus/player_selection/selection.tscn")
var map_scene = preload("res://menus/map_selection/map_selection.tscn")

func _ready():
	if g.new_game:
		add_child(title_scene.instance())
		$Splashscreen.visible = true
		var music_player = $AudioStreamPlayer
		music_player.stream = load('res://sfx/title_screen.mp3')
		music_player.play()
		$Timer.start()
	else:
		$Splashscreen.visible = false
		add_child(selection_scene.instance())

	
func _on_Timer_timeout():
	$Splashscreen.visible = false

func switch_screen(screen_name, current):
	if screen_name == 'title':
		add_child(title_scene.instance())
	if screen_name == 'select':
		add_child(selection_scene.instance())
	if screen_name == 'map':
		add_child(map_scene.instance())
	current.queue_free()

