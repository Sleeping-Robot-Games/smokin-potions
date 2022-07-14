extends Node

signal elements_changed(elements, number)

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

var players_in_current_game = []

var level_selected = 'rock_garden'


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
	
func load_player(parent_node: Node2D, player_number: String):
	var f = File.new()
	f.open("user://player_state_P"+str(player_number)+".save", File.READ)
	var json = JSON.parse(f.get_as_text())
	f.close()
	var data = json.result
	for part in parent_node.get_children():
		if part is Sprite:
			if part.name == 'Hair' or part.name == 'Hat':
				part.texture = load(data.sprite_state[part.name])
			if part.name == 'Robe' or part.name == 'Hat':
				part.material.set_shader_param("palette_swap", load("res://players/wizard/creator/palette/Color/Color_"+data.pallete_sprite_state["Color"]+".png"))
				part.material.set_shader_param("greyscale_palette", load("res://players/wizard/creator/palette/Color/Color_000.png"))
			elif part.name == 'Hair':
				part.material.set_shader_param("palette_swap", load("res://players/wizard/creator/palette/"+part.name+"color/"+part.name+"color_"+data.pallete_sprite_state[part.name+'color']+".png"))
				part.material.set_shader_param("greyscale_palette", load("res://players/wizard/creator/palette/"+part.name+"color/"+part.name+"color_000.png"))
			else:
				part.material.set_shader_param("palette_swap", load("res://players/wizard/creator/palette/"+part.name+"/"+part.name+"_"+data.pallete_sprite_state[part.name]+".png"))
				part.material.set_shader_param("greyscale_palette", load("res://players/wizard/creator/palette/"+part.name+"/"+part.name+"_000.png"))
			make_shaders_unique(part)
			
func load_normal_assets(parent_node: Node2D, player_number: String):
	var f = File.new()
	f.open("user://player_state_P"+str(player_number)+".save", File.READ)
	var json = JSON.parse(f.get_as_text())
	f.close()
	var data = json.result
	for part in parent_node.get_children():
		if part is Sprite:
			if part.name == 'Hair' or part.name == 'Hat':
				part.texture = load(data.sprite_state[part.name])
			else:
				part.texture = load('res://players/wizard/Body/'+part.name+'.png')
				
func load_hold_assets(parent_node: Node2D, player_number: String):
	var f = File.new()
	f.open("user://player_state_P"+str(player_number)+".save", File.READ)
	var json = JSON.parse(f.get_as_text())
	f.close()
	var data = json.result
	for part in parent_node.get_children():
		if part is Sprite:
			if part.name == 'Hair' or part.name == 'Hat':
				var sprite_number = data.sprite_state[part.name].substr(len(data.sprite_state[part.name])-7, 3)
				part.texture = load('res://players/wizard/'+part.name+'throw/'+part.name+'_'+sprite_number+'.png')
			else:
				part.texture = load('res://players/wizard/Bodythrow/'+part.name+'.png')
	
func reparent(node, new_parent):
	node.get_parent().remove_child(node)
	new_parent.add_child(node)
