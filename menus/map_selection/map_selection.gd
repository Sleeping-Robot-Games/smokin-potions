extends Node2D

func _ready():
	pass 


func _on_Map_Selected_button_up(map_name):
	g.level_selected = map_name
	
	$AudioStreamPlayer.volume_db = 10
	$AudioStreamPlayer.stream = load('res://sfx/menu_confirmation.ogg')
	$AudioStreamPlayer.connect("finished", self, "_on_finished")
	$AudioStreamPlayer.play()

func _on_finished():
	get_tree().change_scene("res://levels/"+g.level_selected+"/"+g.level_selected+".tscn")


func _on_WizardTowerButton_mouse_entered():
	g.play_sfx(self, 'menu_selection')


func _on_RockGardenButton_mouse_entered():
	g.play_sfx(self, 'menu_selection')


func _on_Button_button_up():
	var music_player = get_parent().get_node("AudioStreamPlayer")
	music_player.stream = load('res://sfx/seth_song_3_v2.ogg')
	music_player.play()
	g.play_sfx(self, 'menu_confirmation', 10)
	g.players_in_current_game = []
	get_parent().switch_screen('select', self)
