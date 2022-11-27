extends Node2D


func _ready():
	if not g.new_game:
		_on_Button_button_up()
	$Sprite/AnimationPlayer.play("jiggle")


func _input(event):
	if visible:
		if event is InputEventJoypadButton and event.is_action_pressed('ui_press'):
			print(visible)
			print('START MENU SHIT')
			g.p1_using_controller = true
			get_parent().create_cursor(1)
		elif event is InputEventMouseButton and event.is_action_pressed('ui_press'):
			print('START MENU SHIT')
			g.p1_using_controller = false
			get_parent().remove_cursor(1)


func _on_Button_button_up():
	visible = false
	get_parent().get_node("Select").visible = true
	get_parent().get_node("Select/Boxes/Box1/Random").grab_focus()
	var music_player = get_parent().get_node("AudioStreamPlayer")
	music_player.stream = load('res://sfx/seth_song_3_v2.ogg')
	music_player.play()
	g.play_sfx(self, 'menu_confirmation', 10)
	

