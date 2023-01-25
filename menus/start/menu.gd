extends Node

var title_scene = preload("res://menus/start/Title.tscn")
var selection_scene = preload("res://menus/player_selection/selection.tscn")
var map_scene = preload("res://menus/map_selection/map_selection.tscn")

var title = null

func _ready():
	if g.new_game:
		title = title_scene.instance()
		add_child(title)
		title.visible = false
		$SrgSplash.visible = true
		$SrgSplash.get_node("AnimationPlayer").play("SRG")
		$SrgSplash.get_node("AnimationPlayer").connect("animation_finished", self, 'on_Animation_finished')
		var music_player = $AudioStreamPlayer
		music_player.stream = load('res://sfx/title_screen.mp3')
		music_player.play()
	else:
		$SrgSplash.visible = false
		add_child(selection_scene.instance())


func switch_screen(screen_name, current):
	if screen_name == 'title':
		add_child(title_scene.instance())
	if screen_name == 'select':
		add_child(selection_scene.instance())
	if screen_name == 'map':
		add_child(map_scene.instance())
	current.queue_free()

func on_Animation_finished(anim_name):
	title.visible = true
	$SrgSplash.visible = false
	print(anim_name)
	print('animation done')
