extends Node

onready var potion_basic = preload('res://potions/basic/basic.tscn')
onready var potion_fire = preload("res://potions/fire/fire.tscn")

onready var potion_dict = {
	'basic': potion_basic,
	'fire': potion_fire
}

func get_potion_scene(elements):
	if elements.size() == 0:
		return potion_basic
	if elements.size() == 1:
		return potion_dict[elements[0]]
	if elements.size() == 2:
		return potion_dict[elements[0]+elements[1]] or potion_dict[elements[1]+elements[0]]


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

func set_sprite_color(folder, sprite: Sprite, number: String) -> void:
	var palette_path = "res://Assets/Palettes/{folder}/{folder}color_{number}.png".format({
		"folder": folder,
		"number": number
	})
	var gray_palette_path = "res://Assets/Palettes/{folder}/{folder}color_000.png".format({
		"folder": folder
	})
	sprite.material.set_shader_param("palette_swap", load(palette_path))
	sprite.material.set_shader_param("greyscale_palette", load(gray_palette_path))
	make_shaders_unique(sprite)

func make_shaders_unique(sprite: Sprite):
	var mat = sprite.get_material().duplicate()
	sprite.set_material(mat)
	
	
