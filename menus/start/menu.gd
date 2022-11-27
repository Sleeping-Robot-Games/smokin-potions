extends Node

var cursor_scene = preload("res://menus/start/Cursor.tscn")
var title_scene = preload("res://menus/start/Title.tscn")
var selection_scene = preload("res://menus/player_selection/selection.tscn")
var map_scene = preload("res://menus/map_selection/map_selection.tscn")

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

func switch_screen(screen_name, current):
	if screen_name == 'title':
		add_child(title_scene.instance())
	if screen_name == 'select':
		add_child(selection_scene.instance())
	if screen_name == 'map':
		add_child(map_scene.instance())
	print(current.name)
	current.queue_free()

func create_cursor(p_num):
	var cursor = get_node_or_null(str(p_num)+'cursor')
	if not cursor:
		var new_cursor = cursor_scene.instance()
		new_cursor.p_num = p_num
		new_cursor.position = Vector2(320, 240)
		new_cursor.name = str(p_num)+'cursor'
		add_child(new_cursor)

func remove_cursor(p_num):
	var cursor = get_node_or_null(str(p_num)+'cursor')
	if cursor:
		cursor.queue_free()
