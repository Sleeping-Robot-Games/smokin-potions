extends Control

export (bool) var player: int = false

onready var wizard_sprite = {
	'Body': $Wizard/Body,
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
		wizard_sprite['Outline']
	],
	'Haircolor': [wizard_sprite['Hair']],
	'Skin': [
		wizard_sprite['Skin'],
		wizard_sprite['Body'],
	]
}


var sprite_folder_path = "res://players/wizard/"
var palette_folder_path = "res://players/wizard/Palette/"


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
	var random_sprite = random_asset(sprite_folder_path + sprite_name, 'Body')
	if random_sprite == "": # No assets in the folder yet continue to next folder
		return
	if "000" in random_sprite: # Prevent some empty sprite sheets
		if sprite_name == "HairA" and "Hair" in random_sprite: # If main hair is bald, leave rest of hair
			return
		if "Top" in sprite_name or "Bottom" in sprite_name: # If no top or no bottom was returned, dont set the texture
			return
	set_sprite_texture(sprite_name, random_sprite)

func _on_Color_Left_button_up():
	pass
	#wizard_body.material.set_shader_param("palette_swap", load("res://players/wizard/Body"+data[part.name].palette_name))


func _on_Color_Right_button_up():
	pass # Replace with function body.
