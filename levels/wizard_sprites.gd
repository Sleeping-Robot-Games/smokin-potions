extends Node2D

export (bool) var use_export_vars = false
export (int) var frame: int
export (String) var p_number: String

func _ready():
	if use_export_vars:
		for sprite in get_children():
			sprite.frame = frame
		g.load_player(self, p_number)
	else:
		var player_number = get_parent().get_parent().name.substr(1,1)
		print( get_parent().get_parent().name)
		for sprite in get_children():
			sprite.frame = 3 if player_number == '1' or player_number == '3' else 0
		g.load_player(self, player_number)
