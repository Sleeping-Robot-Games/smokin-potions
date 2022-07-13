extends Node2D

var used_colors = []

func _ready():
	var boxes = $Boxes.get_children()
	for box in boxes:
		box.create_random_character()
		box.get_node('Wizard').disabled = true

func add_color(color):
	used_colors.append(color)
	
func remove_color(color):
	used_colors.erase(color)
