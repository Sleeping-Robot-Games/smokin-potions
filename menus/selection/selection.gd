extends Node2D

var used_colors = []

func _ready():
	pass 

func add_color(color):
	used_colors.append(color)
	
func remove_color(color):
	used_colors.erase(color)
