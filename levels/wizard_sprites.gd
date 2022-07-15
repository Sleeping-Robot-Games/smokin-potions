extends Node2D


func _ready():
	var player_number = get_parent().get_parent().name.substr(1,1)
	for sprite in get_children():
		sprite.frame = 3 if player_number == '1' or player_number == '3' else 0
	g.load_player(self, player_number)
