extends Node2D
# warning-ignore-all:return_value_discarded

func _ready():
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	get_parent().connect('cursor_changed', self, "_on_Menu_cursor_changed")
	
	var p1_cursor = get_node_or_null('/root/Menu/1cursor')
	if Input.get_connected_joypads().size() > 0:
		if p1_cursor:
			$ControllerLabel.text = 'Left click on mouse to use Mouse/Keyboard'
		else:
			$ControllerLabel.text = 'Press any button to use controller'
	else:
		$ControllerLabel.text = 'Connect controller to play with one'
	if not g.new_game:
		_on_Button_button_up()
	$Sprite/AnimationPlayer.play("jiggle")


func _on_joy_connection_changed(device_id, connected):
	if connected:
		if not g.player_input_devices.values().has("joy_" + str(device_id)):
			for i in g.player_input_devices:
				if g.player_input_devices[i] == null:
					g.player_input_devices[i] = "joy_" + str(device_id)
					get_parent().create_cursor(int(i.substr(1,1)))
					return
	else:
		for i in g.player_input_devices:
			if g.player_input_devices[i] == "joy_" + str(device_id):
				g.player_input_devices[i] = null
				get_parent().remove_cursor(int(i.substr(1,1)))
				return


func _input(event):
	if event.is_action_pressed('ui_press_kb'):
		g.player_input_devices["p1"] = "keyboard"
		get_parent().remove_cursor(1)
	elif event.is_action_pressed('any_pad_button'):
		var device_name = Input.get_joy_name(event.device)
		if g.ghost_inputs.has(device_name):
			return
		g.player_input_devices["p1"] = "joy_" + str(event.device)
		get_parent().create_cursor(1)


func _on_Button_button_up():
	var music_player = get_parent().get_node("AudioStreamPlayer")
	music_player.stream = load('res://sfx/seth_song_3_v2.ogg')
	music_player.play()
	g.play_sfx(self, 'menu_confirmation', 10)
	get_parent().switch_screen('select', self)
	


func _on_Menu_cursor_changed(connected):
	if connected:
		$ControllerLabel.text = 'Left click on mouse to use Mouse/Keyboard'
	else:
		if Input.get_connected_joypads().size() > 0:
			$ControllerLabel.text = 'Press any button to use controller'
		else:
			$ControllerLabel.text = 'Connect controller to play with one'
