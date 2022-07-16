extends Node

var rng = RandomNumberGenerator.new()

signal elements_changed(elements, number)
signal health_changed(health)
signal player_death(player)
signal player_revive(player)

onready var potion_basic = preload('res://potions/basic/basic.tscn')
onready var potion_fire = preload("res://potions/fire/fire.tscn")
onready var potion_fire_fire = preload("res://potions/fire_fire/fire_fire.tscn")
onready var potion_fire_ice = preload("res://potions/fire_ice/fire_ice.tscn")
onready var potion_fire_earth = preload("res://potions/fire_earth/fire_earth.tscn")
onready var potion_fire_arcane = preload("res://potions/fire_arcane/fire_arcane.tscn")
#onready var potion_ice = preload("res://potions/ice/ice.tscn")
#onready var potion_ice_ice = preload("res://potions/ice_ice/ice_ice.tscn")
#onready var potion_ice_earth = preload("res://potions/ice_earth/ice_earth.tscn")
onready var potion_ice_arcane = preload("res://potions/ice_arcane/ice_arcane.tscn")
onready var potion_earth = preload("res://potions/earth/earth.tscn")
onready var potion_earth_earth = preload("res://potions/earth_earth/earth_earth.tscn")
onready var potion_earth_arcane = preload("res://potions/earth_arcane/earth_arcane.tscn")
onready var potion_arcane = preload("res://potions/arcane/arcane.tscn")
onready var potion_arcane_arcane = preload("res://potions/arcane_arcane/arcane_arcane.tscn")



onready var potion_dict = {
	'basic': potion_basic,
	'fire': potion_fire,
	'fire_fire': potion_fire_fire,
	'fire_arcane': potion_fire_arcane,
	'fire_ice': potion_fire_ice,
	'fire_earth': potion_fire_earth,
	#'ice': potion_ice,
	#'ice_ice': potion_ice_ice,
	#'ice_earth': potion_ice_earth,
	'ice_arcane': potion_ice_arcane,
	'earth': potion_earth,
	'earth_earth': potion_earth_earth,
	'earth_arcane': potion_earth_arcane,
	'arcane': potion_arcane,
	'arcane_arcane': potion_arcane_arcane,
}

var players_in_current_game = []

var level_selected = 'rock_garden'

var new_game = true


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

func folders_in_dir(path: String) -> Array:
	var folders = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true, true)
	while true:
		var folder = dir.get_next()
		if folder == "":
			break
		if not folder.begins_with("."):
			folders.append(folder)
	dir.list_dir_end()
	return folders

func files_in_dir(path: String, keyword: String = "") -> Array:
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true, true)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		if keyword != "" and file.find(keyword) == -1:
			continue
		if not file.begins_with(".") and file.ends_with(".import"):
			files.append(file.replace(".import", ""))
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
	return data
			
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


func play_random_sfx_2D(parent, name):
	var sfx_player = AudioStreamPlayer2D.new()
	rng.randomize()
	var track_num = rng.randi_range(1, 5)
	sfx_player.stream = load('res://sfx/'+name+'_'+str(track_num)+'.ogg')
	sfx_player.connect("finished", sfx_player, "queue_free")
	parent.add_child(sfx_player)
	sfx_player.play()
	
func play_random_sfx(parent, name):
	var sfx_player = AudioStreamPlayer.new()
	rng.randomize()
	var track_num = rng.randi_range(1, 5)
	sfx_player.stream = load('res://sfx/'+name+'_'+str(track_num)+'.ogg')
	sfx_player.connect("finished", sfx_player, "queue_free")
	parent.add_child(sfx_player)
	sfx_player.play()


func play_sfx_2D(parent, name):
	var sfx_player = AudioStreamPlayer2D.new()
	rng.randomize()
	var track_num = rng.randi_range(1, 5)
	sfx_player.stream = load('res://sfx/'+name+'.ogg')
	sfx_player.connect("finished", sfx_player, "queue_free")
	parent.add_child(sfx_player)
	sfx_player.play()

func play_sfx(parent, name):
	var sfx_player = AudioStreamPlayer.new()
	rng.randomize()
	var track_num = rng.randi_range(1, 5)
	sfx_player.stream = load('res://sfx/'+name+'.ogg')
	sfx_player.connect("finished", sfx_player, "queue_free")
	parent.add_child(sfx_player)
	sfx_player.play()
