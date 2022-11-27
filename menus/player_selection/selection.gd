extends Node2D

var used_colors = []
var ready_players = []
var players = []

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

func _input(event):
	if not visible:
		return
	if event is InputEventJoypadButton and event.is_action_pressed('ui_press'):
		var p_num = event.device + 1 if g.p1_using_controller else 2
		var cursor = get_node_or_null('/root/Menu/'+str(p_num)+'cursor')
		var box = get_node('Boxes/Box'+str(p_num))
		if not box.player:
			player_join(p_num, cursor == null)

func _on_joy_connection_changed(device_id, connected):
	var p_num = device_id + 1 if g.p1_using_controller else 2
	if connected:
		player_join(p_num, connected)
	else:
		player_leave(p_num, connected)


func add_color(color):
	used_colors.append(color)
	
func remove_color(color):
	used_colors.erase(color)
	
func player_join(p_num, newly_connected = false):
	## Adds the player to the box
	var new_player_box = $Boxes.get_node("Box"+str(p_num))
	new_player_box.player = true
	new_player_box.apply_box_ui()
	players.append(new_player_box)
	if newly_connected:
		## Creates a cursor
		get_node('/root/Menu/').create_cursor(p_num)
	
func player_leave(p_num, connected = true):
	## Remove the player from the box
	var new_player_box = $Boxes.get_node("Box"+str(p_num))
	new_player_box.player = false
	new_player_box.apply_box_ui()
	players.erase(new_player_box)
	if not connected:
		## Removes the cursor
		get_node('/root/Menu/').remove_cursor(p_num)

func all_players_leave():
	for box in $Boxes.get_children():
		if box.number != '1' and box.player:
			player_leave(int(box.number), false)

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
		visible = false
		get_parent().get_node("MapSection").visible = true

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
