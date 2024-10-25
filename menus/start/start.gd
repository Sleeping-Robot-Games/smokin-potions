extends Node2D
# warning-ignore-all:return_value_discarded

func _ready():
	g.connect('cursor_changed', self, "_on_Menu_cursor_changed")
	
	var p1_cursor = get_node_or_null('/root/Menu/1cursor')
	if Input.get_connected_joypads().size() > 0:
		if p1_cursor:
			$ControllerLabel.text = 'Left-click to switch to Mouse/Keyboard controls'
		else:
			$ControllerLabel.text = 'Press any button to switch to controller'
	else:
		$ControllerLabel.text = 'Connect a controller to enable controller support'
	if not g.new_game:
		_on_Button_button_up()
	$Sprite/AnimationPlayer.play("jiggle")



func _input(event):
	if event.is_action_pressed('ui_press_kb'):
		g.player_input_devices["p1"] = "keyboard"
		g.remove_cursor(1, get_parent())
	elif event.is_action_pressed('any_pad_button'):
		var device_name = Input.get_joy_name(event.device)
		if g.ghost_inputs.has(device_name):
			return
		g.player_input_devices["p1"] = "joy_" + str(event.device)
		g.create_cursor(1, get_parent())


func _on_Button_button_up():
	var music_player = get_parent().get_node("AudioStreamPlayer")
	music_player.stream = load('res://sfx/seth_song_3_v2.ogg')
	music_player.play()
	g.play_sfx(self, 'menu_confirmation', 10)
	get_parent().switch_screen('select', self)
	


func _on_Menu_cursor_changed(connected):
	if connected:
		$ControllerLabel.text = 'Left-click to switch to Mouse/Keyboard controls'
	else:
		if Input.get_connected_joypads().size() > 0:
			$ControllerLabel.text = 'Press any button to switch to controller'
		else:
			$ControllerLabel.text = 'Connect a controller to enable controller support'
