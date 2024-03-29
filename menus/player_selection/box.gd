extends Control
# warning-ignore-all:return_value_discarded

var rng = RandomNumberGenerator.new()

export (bool) var player: bool = false
export (bool) var none: bool = false
export (bool) var ready_disabled: bool = false

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

onready var selection = get_parent().get_parent()
onready var number = self.name.substr(3,1)

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
	
	apply_box_ui()


func apply_box_ui():
	# Ready or join button
	if player:
		var input_sprite = null
		var input_device = g.player_input_devices["p"+number]
		if input_device == "keyboard":
			input_sprite = "keyboard.png"
		elif input_device and "joy_" in input_device:
			input_sprite = "controller.png"
		
		if input_sprite:
			$ControlType.visible = true
			$ControlType.set_texture(load("res://menus/player_selection/"+input_sprite))
		else:
			$ControlType.visible = false
			$ControlType.set_texture(null)
		$Leave.show()
	else:
		$ControlType.visible = false
	
	if not none:
		# Remove UI from bots
		$Color.visible = player
		$Hat.visible = player
		$Hair.visible = player
		$Skin.visible = player
		$HairColor.visible = player
		$CheckBox.visible = player
		$CheckBox.disabled = !player or ready_disabled
		$RemoveBot.visible = !player
		$Name.text = "P"+ number if player else "Bot"
		$AddBot.visible = false
		$Wizard.visible = true
		$Random.visible = true
	else:
		# Remove all UI if none
		$AddBot.visible = true
		$Color.visible = false
		$Hat.visible = false
		$Hair.visible = false
		$Skin.visible = false
		$HairColor.visible = false
		$CheckBox.visible = false
		$CheckBox.disabled = true
		$RemoveBot.visible = false
		$Name.text = ""
		$Wizard.visible = false
		$Random.visible = false


func set_sprite_texture(sprite_name: String, texture_path: String) -> void:
	wizard_sprite[sprite_name].set_texture(load(texture_path))
	sprite_state[sprite_name] = texture_path


func set_sprite_color(folder, sprite: Sprite, color_num: String) -> void:
	var palette_path = "res://players/wizard/creator/palette/{folder}/{folder}_{color_num}.png".format({
		"folder": folder,
		"color_num": color_num
	})
	var gray_palette_path = "res://players/wizard/creator/palette/{folder}/{folder}_000.png".format({
		"folder": folder
	})
	sprite.material.set_shader_param("palette_swap", load(palette_path))
	sprite.material.set_shader_param("greyscale_palette", load(gray_palette_path))
	g.make_shaders_unique(sprite)


func random_asset(folder: String, keyword: String = "") -> String:
	var files: Array
	files = g.files_in_dir(folder)
	if keyword == "":
		files = g.files_in_dir(folder)
	if files.size() == 0:
		return ""
	rng.randomize()
	var random_index = rng.randi_range(0, files.size() - 1)
	return folder+"/"+files[random_index]


func set_random_color(palette_type: String) -> void:
	var random_color
	if palette_type == 'Color':
		var available_colors = []
		var all_colors = g.files_in_dir(palette_folder_path+'Color')
		for color in all_colors:
			if not '000' in color and not selection.used_colors.has(color):
				available_colors.append(color)
		rng.randomize()
		var random_index = rng.randi_range(0, available_colors.size() - 1)
		random_color = available_colors[random_index]
		selection.add_color(random_color)
		if 'Color' in pallete_sprite_state.keys():
			selection.remove_color("Color_" + pallete_sprite_state['Color'] + ".png")
	else:
		random_color = random_asset(palette_folder_path + palette_type)
	if random_color == "" or "000" in random_color:
		random_color = random_color.replace("000", "001")
	for sprite in wizard_sprite_palette[palette_type]:
		var color_num = random_color.substr(len(random_color)-7, 3)
		set_sprite_color(palette_type, sprite, color_num)
		pallete_sprite_state[palette_type] = color_num


func set_random_texture(sprite_name: String) -> void:
	var random_sprite = random_asset(sprite_folder_path + sprite_name)
	if random_sprite == "": # No assets in the folder yet continue to next folder
		return
	set_sprite_texture(sprite_name, random_sprite)


func create_random_character() -> void:
	var sprite_folders = g.folders_in_dir(sprite_folder_path)
	var palette_folders = g.folders_in_dir(palette_folder_path)
	for folder in sprite_folders:
		set_random_texture(folder)
	for folder in palette_folders:
		set_random_color(folder)


func create_loaded_character() -> void:
	var loaded_data = g.load_player($Wizard, number)
	sprite_state = loaded_data.sprite_state
	pallete_sprite_state = loaded_data.pallete_sprite_state


func _on_Random_button_up():
	create_random_character()
	g.play_sfx(self, 'menu_selection')


func get_next_avail_color(direction):
	var all_colors = g.files_in_dir(palette_folder_path + "Color/")
	var current_color_index = all_colors.find("Color_" + pallete_sprite_state['Color'] + ".png")
	var reordered_colors = all_colors.slice(current_color_index, all_colors.size()-1) + all_colors.slice(1, current_color_index)
	if direction == -1:
		reordered_colors.invert()
	for color in reordered_colors:
		if not color in selection.used_colors:
			return color.substr(6, 3)


func disable_ready() -> void:
	ready_disabled = true
	$CheckBox.set_pressed_no_signal(false)
	apply_box_ui()


func enable_ready() -> void:
	ready_disabled = false
	apply_box_ui()


func _on_Color_Selection_button_up(direction: int, palette_sprite: String):
	g.play_sfx(self, 'menu_selection')
	if palette_sprite == 'Color':
		var folder_path = palette_folder_path + palette_sprite
		var files = g.files_in_dir(folder_path)
		var new_color = get_next_avail_color(direction)
		selection.remove_color("Color_" + pallete_sprite_state['Color'] + ".png")
		for sprite in wizard_sprite_palette[palette_sprite]:
			var color_num = str(new_color).pad_zeros(3)
			set_sprite_color(palette_sprite, sprite, color_num)
			pallete_sprite_state[palette_sprite] = color_num
		selection.add_color("Color_" + pallete_sprite_state['Color'] + ".png")
	else:
		var folder_path = palette_folder_path + palette_sprite
		var files = g.files_in_dir(folder_path)
		var new_color = int(pallete_sprite_state[palette_sprite]) + direction
		if new_color == 0 and direction == -1:
			new_color = len(files) - 1
		if new_color == len(files) and direction == 1:
			new_color = 1
		for sprite in wizard_sprite_palette[palette_sprite]:
			var color_num = str(new_color).pad_zeros(3)
			set_sprite_color(palette_sprite, sprite, color_num)
			pallete_sprite_state[palette_sprite] = color_num


func _on_Sprite_Selection_button_up(direction: int, sprite: String):
	g.play_sfx(self, 'menu_selection')
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


func _on_CheckBox_toggled(ready):
	g.play_sfx(self, 'menu_confirmation', 10)
	if ready:
		selection.player_ready(self)
	else:
		selection.player_not_ready(self)


func _on_Leave_button_up():
	$Leave.disabled = true
	g.play_sfx(self, 'menu_selection')
	$Leave/Timer.start()

func _on_LeaveTimer_timeout():
	$Leave.hide()
	get_node('/root/Menu/Select').player_leave(int(number))
	$Leave.disabled = false

func _on_RemoveBot_button_up():
	get_node('/root/Menu/Select').bot_leave(int(number))


func _on_AddBot_button_up():
	get_node('/root/Menu/Select').bot_join(int(number))


func _on_Timer_timeout():
	pass # Replace with function body.

