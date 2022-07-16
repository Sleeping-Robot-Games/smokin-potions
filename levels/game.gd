extends Node

onready var wizard = preload('res://players/wizard/wizard.tscn')
onready var bot = preload("res://players/bots/bot.tscn")
onready var ui = preload('res://levels/player_ui.tscn')
onready var breakable = preload('res://levels/breakable.tscn')
onready var wizard_sprites = preload('res://levels/wizard_sprites.tscn')

onready var match_time = get_node("HUD/MatchTime")
var seconds = 120
var current_players = []
var dead_players = []
var win_state = {}
var last_winner
var breakable_positions = []

func _ready():
	
	g.connect("elements_changed", self, "handle_elements_changed")
	g.connect("player_death", self, "handle_player_death")
	g.connect("player_revive", self, "handle_player_revive")
	
	## USED FOR DEBUGGING ##
	if g.players_in_current_game.size() == 0:
		g.players_in_current_game = [
			{'number': '1', 'bot': false},
			{'number': '2', 'bot': true},
			{'number': '3', 'bot': true},
			{'number': '4', 'bot': true},
		]
		
	for player in g.players_in_current_game:
		add_player_to_game(player)
		
		
	$HUD/AnimationPlayer.play("show_winner")
	$HUD/WinnerScreen/Star/AnimationPlayer.play("star_bounce")
	$HUD/WinnerScreen/Label.text = 'Player '+'1'+' wins!'
	var wiz_sprites = wizard_sprites.instance()
	wiz_sprites.use_export_vars = true
	wiz_sprites.p_number = '1'
	wiz_sprites.frame = 68
	wiz_sprites.scale = Vector2(3, 3)
	wiz_sprites.position = $HUD/WinnerScreen/Position2D.position
	$HUD/WinnerScreen.add_child(wiz_sprites)
		

func add_player_to_game(player):
	# Adds player to game
	var new_player = wizard.instance() if not player.bot else bot.instance()
	current_players.append(new_player)
	win_state[player.number] = 0
	new_player.number = player.number
	g.load_player(new_player, player.number)
	var starting_pos = get_node("Starting" + str(player.number)).global_position
	new_player.global_position = starting_pos
	$YSort.add_child(new_player)
	
	# Creates the player's UI
	var p_ui = ui.instance()
	p_ui.name = "P"+player.number+"UI"
	$HUD.add_child(p_ui)
	
	
func next_round():
	seconds = 120
	$MatchTimer.start()
	for player in current_players:
		var starting_pos = get_node("Starting" + str(player.number)).global_position
		player.global_position = starting_pos
		player.revive(2)
		player.super_disabled = false
		handle_elements_changed([], player.number)
	for potion in get_tree().get_nodes_in_group('potions'):
		potion.queue_free()
		

func handle_player_death(player):
	dead_players.append(player)
	if dead_players.size() == current_players.size() - 1:
		var winner
		for p in current_players:
			p.super_disabled = true
			if dead_players.find(p) == -1:
				winner = p
				last_winner = p
		
		win_state[winner.number] += 1
		var winner_ui = get_node("HUD/P"+winner.number+"UI")
		winner_ui.play_star_animation(winner.number, str(win_state[winner.number]))
		
		$NextRound.start()
		$MatchTimer.stop()
		for potion in get_tree().get_nodes_in_group('potions'):
			potion.queue_free()

func handle_player_revive(player):
	dead_players.erase(player)

func handle_elements_changed(elements, player_number):
	if elements.size() == 2:
		get_node("HUD/P"+player_number+"UI/Element1").set_texture(load("res://pickups/runes/" + elements[0] + ".png"))
		get_node("HUD/P"+player_number+"UI/Element2").set_texture(load("res://pickups/runes/" + elements[1] + ".png"))
	elif elements.size() == 1:
		get_node("HUD/P"+player_number+"UI/Element1").set_texture(load("res://pickups/runes/" + elements[0] + ".png"))
		get_node("HUD/P"+player_number+"UI/Element2").texture = null
	else:
		get_node("HUD/P"+player_number+"UI/Element1").texture = null
		get_node("HUD/P"+player_number+"UI/Element2").texture = null


func _on_MatchTimer_timeout():
	if seconds > 0:
		seconds -= 1
		if seconds <= 0:
			match_time.bbcode_text = '[center][color=red]OVERTIME[/color][/center]'
		else:
			match_time.bbcode_text = '[center]' + format_time() + '[/center]'
	else:
		match_time.bbcode_text = '[center][color=red]OVERTIME[/color][/center]'


func format_time():
	return str(abs(ceil(seconds/60))).pad_zeros(2) + ":" + str("%01d" % abs(ceil(seconds % 60))).pad_zeros(2)


func _on_NextRound_timeout():
	if win_state[last_winner.number] == 3:
		for potion in get_tree().get_nodes_in_group('potions'):
			potion.queue_free()
		for ui in get_tree().get_nodes_in_group('player_ui'):
			ui.visible = false
		$HUD/AnimationPlayer.play("show_winner")
		$HUD/WinnerScreen/Star/AnimationPlayer.play("star_bounce")
		$HUD/WinnerScreen/Label.text = 'Player '+last_winner.number+' wins!'
		var wiz_sprites = wizard_sprites.instance()
		wiz_sprites.use_export_vars = true
		wiz_sprites.p_number = last_winner.number
		wiz_sprites.frame = 68
		wiz_sprites.position = $HUD/WinnerScreen/Position2D.position
		$HUD/WinnerScreen.add_child(wiz_sprites)
	else:
		next_round()


func _on_Button_button_up():
	g.players_in_current_game = []
	get_tree().change_scene("res://menus/start/start.tscn")
	g.new_game = false
