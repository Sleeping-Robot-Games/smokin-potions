extends Control

export (bool) var player: int = false

onready var wizard_sprite = {
	'Hat': $Wizard/Hat,
	'Skin': $Wizard/Skin,
	'Robe': $Wizard/Robe,
	'Hair': $Wizard/Hair,
	'Outline': $Wizard/Outline
}

onready var wizard_sprite_palette = {
	'Color': [
		wizard_sprite['Hat'],
		wizard_sprite['Robe'],
	],
	'Haircolor': [wizard_sprite['Hair']],
	'Skin': [wizard_sprite['Skin']],
	'Outline': [wizard_sprite['Outline']]
}

var pallete_sprite_state: Dictionary
var sprite_state: Dictionary

var sprite_folder_path = "res://players/wizard/creator/sprites/"
var palette_folder_path = "res://players/wizard/creator/palette/"


func _ready():
	# Connect buttons
	$Color/Left.connect('button_up', self, '_on_Color_Selection_button_up', [-1, "Color"])
	$Color/Right.connect('button_up', self, '_on_Color_Selection_button_up', [1, "Color"])
	$Skin/Left.connect('button_up', self, '_on_Color_Selection_button_up', [-1, "Skin"])
	$Skin/Right.connect('button_up', self, '_on_Color_Selection_button_up', [1, "Skin"])
	$HairColor/Left.connect('button_up', self, '_on_Color_Selection_button_up', [-1, "Haircolor"])
	$HairColor/Right.connect('button_up', self, '_on_Color_Selection_button_up', [1, "Haircolor"])
	$Hat/Left.connect('button_up', self, '_on_Sprite_Selection_button_up', [-1, "Hat"])
	$Hat/Right.connect('button_up', self, '_on_Sprite_Selection_button_up', [1, "Hat"])
	$Hair/Left.connect('button_up', self, '_on_Sprite_Selection_button_up', [-1, "Hair"])
	$Hair/Right.connect('button_up', self, '_on_Sprite_Selection_button_up', [1, "Hair"])
	
	# Create random character
	create_random_character()
	
	# Remove UI from bots
	if not player:
		$Color.visible = false
		$Hat.visible = false
		$Hair.visible = false
		$Skin.visible = false
		$HairColor.visible = false
		$Name.text = "Bot"

func set_sprite_texture(sprite_name: String, texture_path: String) -> void:
	wizard_sprite[sprite_name].set_texture(load(texture_path))
	sprite_state[sprite_name] = texture_path

func random_asset(folder: String, keyword: String = "") -> String:
	var files: Array
	files = g.files_in_dir(folder)
	if keyword == "":
		files = g.files_in_dir(folder)
	if len(files) == 0:
		return ""
	randomize()
	var random_index = randi() % len(files)
	return folder+"/"+files[random_index]
	
func set_random_color(palette_type: String) -> void:
	var random_color = random_asset(palette_folder_path + palette_type)
	if random_color == "" or "000" in random_color:
		random_color = random_color.replace("000", "001")
	for sprite in wizard_sprite_palette[palette_type]:
		var color_num = random_color.substr(len(random_color)-7, 3)
		g.set_sprite_color(palette_type, sprite, color_num)
		pallete_sprite_state[palette_type] = color_num
		
func set_random_texture(sprite_name: String) -> void:
	var random_sprite = random_asset(sprite_folder_path + sprite_name)
	if random_sprite == "": # No assets in the folder yet continue to next folder
		return
	set_sprite_texture(sprite_name, random_sprite)
	
func create_random_character() -> void:
	var sprite_folders = g.files_in_dir(sprite_folder_path)
	var palette_folders = g.files_in_dir(palette_folder_path)
	for folder in sprite_folders:
		if folder == "Body" or folder == "Palette":
			continue
		set_random_texture(folder)
	for folder in palette_folders:
		set_random_color(folder)
		

func _on_Random_button_up():
	create_random_character()


func _on_Color_Selection_button_up(direction: int, palette_sprite: String):
	var folder_path = palette_folder_path + palette_sprite
	var files = g.files_in_dir(folder_path)
	var new_color = int(pallete_sprite_state[palette_sprite]) + direction
	if new_color == 0 and direction == -1:
		new_color = len(files) - 1
	if new_color == len(files) and direction == 1:
		new_color = 1
	for sprite in wizard_sprite_palette[palette_sprite]:
		var color_num = str(new_color).pad_zeros(3)
		g.set_sprite_color(palette_sprite, sprite, color_num)
		pallete_sprite_state[palette_sprite] = color_num

func _on_Sprite_Selection_button_up(direction: int, sprite: String):
	var folder_path = sprite_folder_path + sprite
	var files = g.files_in_dir(folder_path)
	var file = sprite_state[sprite].split("/")[-1]
	var current_index = files.find(file)
	var new_index = current_index + direction
	if new_index > len(files) - 1:
		new_index = 0
	if new_index == -1:
		new_index = len(files) -1
	var new_sprite_path = folder_path + '/' + files[new_index]
	set_sprite_texture(sprite, new_sprite_path)
