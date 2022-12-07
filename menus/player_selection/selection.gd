extends Node2D
# warning-ignore-all:return_value_discarded

var used_colors = []
var ready_players = []
var players = []
var bots = []

func _ready():
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	
	var boxes = $Boxes.get_children()
	for box in boxes:
		if g.new_game:
			box.create_random_character()
		else:
			box.create_loaded_character()
		box.get_node('Wizard').super_disabled = true
		if box.player:
			players.append(box)
	if players.size() == 1:
		for box in boxes:
			box.disable_ready()


func _input(event):
	if not visible:
		return
	if event.is_action_pressed('ui_accept') and not g.player_input_devices.values().has("keyboard"):
		for i in g.player_input_devices:
				if g.player_input_devices[i] == null:
					g.player_input_devices[i] = "keyboard"
					player_join(int(i.substr(1,1)), false)
					return
	elif event.is_action_pressed('any_pad_button'):
		var device_name = Input.get_joy_name(event.device)
		if g.ghost_inputs.has(device_name):
			return
		if g.player_input_devices.values().has("joy_" + str(event.device)):
			return
		for i in g.player_input_devices:
			if g.player_input_devices[i] == null:
				g.player_input_devices[i] = "joy_" + str(event.device)
				player_join(int(i.substr(1,1)))
				break


func _on_joy_connection_changed(device_id, connected):
	if connected:
		if not g.player_input_devices.values().has("joy_" + str(device_id)):
			for i in g.player_input_devices:
				if g.player_input_devices[i] == null:
					g.player_input_devices[i] = "joy_" + str(device_id)
					player_join(int(i.substr(1,1)))
					return
	else:
		for i in g.player_input_devices:
			if g.player_input_devices[i] == "joy_" + str(device_id):
				g.player_input_devices[i] = null
				player_leave(int(i.substr(1,1)))
				return


func add_color(color):
	used_colors.append(color)


func remove_color(color):
	used_colors.erase(color)


func player_join(p_num, add_cursor = true):
	## Adds the player to the box
	var new_player_box = $Boxes.get_node("Box"+str(p_num))
	new_player_box.player = true
	new_player_box.none = false
	new_player_box.apply_box_ui()
	players.append(new_player_box)
	if players.size() + bots.size() > 1:
		enable_ready_all()
	## Creates a cursor
	if add_cursor:
		get_node('/root/Menu/').create_cursor(p_num)


func player_leave(p_num):
	## Remove the player from the box
	var old_player_box = $Boxes.get_node("Box"+str(p_num))
	old_player_box.player = false
	old_player_box.none = true
	old_player_box.apply_box_ui()
	players.erase(old_player_box)
	if players.size() + bots.size() == 1:
		disable_ready_all()
	elif players.size() == 0:
		go_back()
	g.player_input_devices["p"+str(p_num)] = null
	## Removes the cursor
	get_node('/root/Menu/').remove_cursor(p_num)


func bot_join(p_num):
	## Adds the bot to the box
	var new_bot_box = $Boxes.get_node("Box"+str(p_num))
	new_bot_box.none = false
	new_bot_box.player = false
	new_bot_box.apply_box_ui()
	bots.append(new_bot_box)
	if players.size() + bots.size() > 1:
		enable_ready_all()


func bot_leave(p_num):
	## Remove the bot from the box
	var old_bot_box = $Boxes.get_node("Box"+str(p_num))
	old_bot_box.none = true
	old_bot_box.apply_box_ui()
	bots.erase(old_bot_box)
	if players.size() + bots.size() == 1:
		disable_ready_all()


func go_back():
	reset_players()
	var music_player = get_node("/root/Menu/AudioStreamPlayer")
	music_player.stream = load('res://sfx/title_screen.mp3')
	music_player.play()
	g.play_sfx(self, 'menu_confirmation', 10)
	get_node('/root/Menu').switch_screen('title', get_node('/root/Menu/Select'))


func reset_players():
	var boxes = $Boxes.get_children()
	for box in boxes:
		if box.number != '1' and box.player:
			player_leave(int(box.number))


func enable_ready_all():
	var boxes = $Boxes.get_children()
	for box in boxes:
		box.enable_ready()


func disable_ready_all():
	var boxes = $Boxes.get_children()
	for box in boxes:
		box.disable_ready()


func player_ready(player):
	ready_players.append(player)
	store_player_state(player)
	if players.size() == ready_players.size():
		# When all players are ready and saved, save bot states
		for box in $Boxes.get_children():
			if not box.none:
				g.players_in_current_game.append({
					'number': box.number,
					'bot': !box.player
				})
				if not box.player:
					store_player_state(box)
			# Reset ready checkbox if players go back to this screen
			var ready_checkbox = box.get_node('CheckBox')
			if ready_checkbox:
				ready_checkbox.pressed = false
		
		# Reset ready player state
		ready_players = []
		get_parent().switch_screen('map', self)


func player_not_ready(player):
	ready_players.erase(player)


func store_player_state(player):
	var player_customized_state = {
		'sprite_state': player.sprite_state,
		'pallete_sprite_state': player.pallete_sprite_state
	}
	var f = File.new()
	f.open("user://player_state_P"+ str(player.number) +".save", File.WRITE)
	f.store_string(JSON.print(player_customized_state, "  ", true))
	f.close()
