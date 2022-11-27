extends Node

var cursor_scene = preload("res://menus/start/Cursor.tscn")

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
