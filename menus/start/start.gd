extends Node2D


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
		if device_id == 0:
			g.p1_using_controller = true
			get_parent().create_cursor(1)
	else:
		g.p1_using_controller = false
		get_parent().remove_cursor(1)

func _input(event):
	if event is InputEventJoypadButton and event.is_action_pressed('any_pad_button_1'):
		g.p1_using_controller = true
		get_parent().create_cursor(1)
	elif event is InputEventMouseButton and event.is_action_pressed('ui_press_0'):
		g.p1_using_controller = false
		get_parent().remove_cursor(1)

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
