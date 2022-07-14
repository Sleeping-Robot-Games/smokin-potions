extends Node2D


func _ready():
	pass 


func _on_Map_Selected_button_up(map_name):
	g.level_selected = map_name
	get_tree().change_scene("res://levels/"+map_name+"/"+map_name+".tscn")
