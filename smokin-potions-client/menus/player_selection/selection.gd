extends Node2D

var used_colors = []
var ready_players = []
var players = []

func _ready():
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

func add_color(color):
	used_colors.append(color)
	
func remove_color(color):
	used_colors.erase(color)

func player_ready(player):
	ready_players.append(player)
	store_player_state(player)
	if players.size() == ready_players.size():
		# When all players are ready and saved, save bot states
		for box in $Boxes.get_children():
			if box.none:
				continue
			## TODO: Update this when removing bots from selection
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
