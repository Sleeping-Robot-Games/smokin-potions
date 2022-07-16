extends Node2D

export (int) var frame: int = 3
export (String) var p_number: String = '1'

func _ready():
	if frame:
		for sprite in get_children():
			sprite.frame = frame
		g.load_player(self, p_number)
	else:
		var player_number = get_parent().get_parent().name.substr(1,1)
		for sprite in get_children():
			sprite.frame = 3 if player_number == '1' or player_number == '3' else 0
		g.load_player(self, player_number)
