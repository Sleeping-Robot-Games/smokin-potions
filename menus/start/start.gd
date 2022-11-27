extends Node2D


func _ready():
	if not g.new_game:
		_on_Button_button_up()
	$Sprite/AnimationPlayer.play("jiggle")


func _input(event):
	if event is InputEventJoypadButton and event.is_action_pressed('ui_press_1'):
		g.p1_using_controller = true
		get_parent().create_cursor(1)
	elif event is InputEventMouseButton and event.is_action_pressed('ui_press_1'):
		g.p1_using_controller = false
		get_parent().remove_cursor(1)


func _on_Button_button_up():
	var music_player = get_parent().get_node("AudioStreamPlayer")
	music_player.stream = load('res://sfx/seth_song_3_v2.ogg')
	music_player.play()
	g.play_sfx(self, 'menu_confirmation', 10)
	get_parent().switch_screen('select', self)
	

