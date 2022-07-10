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


var sprite_folder_path = "res://players/wizard/creator/sprites/"
var palette_folder_path = "res://players/wizard/creator/palette/"


func _ready():
	if not player:
		$Color.visible = false
		$Hat.visible = false
		$Hair.visible = false
		$Skin.visible = false
		$HairColor.visible = false
		
		$Name.text = "Bot"

func set_sprite_texture(sprite_name: String, texture_path: String) -> void:
	wizard_sprite[sprite_name].set_texture(load(texture_path))

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
		
func _on_Color_Left_button_up():
	pass
	#wizard_body.material.set_shader_param("palette_swap", load("res://players/wizard/Body"+data[part.name].palette_name))


func _on_Color_Right_button_up():
	pass # Replace with function body.


func _on_Random_button_up():
	create_random_character()
