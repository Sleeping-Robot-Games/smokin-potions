extends Node2D


func _ready():
	if not g.new_game:
		_on_Button_button_up()
	$Sprite/AnimationPlayer.play("jiggle")


func _input(event):
	if event.is_action_released("ui_accept") and visible:
		_on_Button_button_up()


func _on_Button_button_up():
	visible = false
	get_parent().get_node("Select").visible = true
	get_parent().get_node("Select/Boxes/Box1/Random").grab_focus()
	var music_player = get_parent().get_node("AudioStreamPlayer")
	music_player.stream = load('res://sfx/seth_song_3_v2.ogg')
	music_player.play()
	g.play_sfx(self, 'menu_confirmation', 10)


func _on_Button_mouse_entered():
	$Button/AnimatedSprite.modulate = Color(1,1,1,1)


func _on_Button_mouse_exited():
	$Button/AnimatedSprite.modulate = Color("#8bbb5a")
