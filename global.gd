extends Node

signal elements_changed(elements)

onready var potion_basic = preload('res://potions/basic/basic.tscn')
onready var potion_fire = preload("res://potions/fire/fire.tscn")
onready var potion_fire_fire = preload("res://potions/fire_fire/fire_fire.tscn")
onready var potion_arcane = preload("res://potions/arcane/arcane.tscn")
onready var potion_arcane_arcane = preload("res://potions/arcane_arcane/arcane_arcane.tscn")

onready var potion_dict = {
	'basic': potion_basic,
	'fire': potion_fire,
	'fire_fire': potion_fire_fire,
	'arcane': potion_arcane,
	'arcane_arcane': potion_arcane_arcane
}


func get_potion_scene(elements):
	if elements.size() == 0:
		return potion_basic
	elif elements.size() == 1 and potion_dict.has(elements[0]):
		return potion_dict[elements[0]]
	elif elements.size() == 2 and potion_dict.has(elements[0] + "_" + elements[1]):
		return potion_dict[elements[0] + "_" + elements[1]]
	elif elements.size() == 2 and potion_dict.has(elements[1] + "_" + elements[0]):
		return potion_dict[elements[1] + "_" + elements[0]]
	else:
		return potion_basic


func files_in_dir(path: String, keyword: String = "") -> Array:
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif keyword != "" and file.find(keyword) == -1:
			continue
		elif not file.begins_with(".") and not file.ends_with(".import"):
			files.append(file)
	dir.list_dir_end()
	return files



func make_shaders_unique(sprite: Sprite):
	var mat = sprite.get_material().duplicate()
	sprite.set_material(mat)
	
func remove_values_from_array(array, values_to_remove):
	pass
	
