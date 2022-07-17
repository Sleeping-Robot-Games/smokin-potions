extends Node

onready var wizard = preload('res://players/wizard/wizard.tscn')
onready var bot = preload("res://players/bots/bot.tscn")
onready var ui = preload('res://levels/player_ui.tscn')
onready var breakable = preload('res://levels/breakable.tscn')
onready var wizard_sprites = preload('res://levels/wizard_sprites.tscn')

onready var match_time = get_node("HUD/MatchTime")
var seconds = 120
var starting_seconds = 3
var current_players = []
var dead_players = []
var win_state = {}
var last_winner
var breakable_positions = []
var reading_controls

func _ready():
	reading_controls = g.new_game
	
	g.connect("elements_changed", self, "handle_elements_changed")
	g.connect("player_death", self, "handle_player_death")
	g.connect("player_revive", self, "handle_player_revive")
	
	print(g.players_in_current_game)
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
	
	if not g.new_game:
		start_game()
	else:
		for ui in get_tree().get_nodes_in_group('player_ui'):
			ui.visible = false
		$HUD/Tutorial.visible = true
		
func _input(event):
	if reading_controls and event is InputEventKey:
		for ui in get_tree().get_nodes_in_group('player_ui'):
			ui.visible = true
		$HUD/Tutorial.visible = false
		start_game()
		reading_controls = false

func start_game():
	starting_seconds = 3
	$StartingTimer.start()
	$HUD/StartingTime.visible = true
	$HUD/StartingTime.text = "Starting in 3..."
	if g.level_selected == "rock_garden":
		$Music.volume_db = -15
		$Music.stream = load('res://sfx/battle_intro_1.mp3')
		$Music.connect("finished", self, "_play_battle_music")
	else:
		$Music.volume_db = 0
		$Music.stream = load('res://sfx/battle_bgm2.mp3')
	$Music.play()
	
func _play_battle_music():
	$Music.stream = load('res://sfx/battle_bgm.ogg')
	$Music.play()

func add_player_to_game(player):
	# Adds player to game
	var new_player = wizard.instance() if not player.bot else bot.instance()
	current_players.append(new_player)
	win_state[player.number] = 0
	new_player.number = player.number
	g.load_player(new_player, player.number)
	var starting_pos = get_node("Starting" + str(player.number)).global_position
	new_player.global_position = starting_pos
	new_player.super_disabled = true
	$YSort.add_child(new_player)
	
	# Creates the player's UI
	var p_ui = ui.instance()
	p_ui.name = "P"+player.number+"UI"
	$HUD.add_child(p_ui)
	
	
func next_round():
	starting_seconds = 3
	$StartingTimer.start()
	$HUD/StartingTime.visible = true
	$HUD/StartingTime.text = "Starting in 3..."
	seconds = 120
	for player in current_players:
		var starting_pos = get_node("Starting" + str(player.number)).global_position
		player.global_position = starting_pos
		player.revive(2)
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
		$HUD/WinnerScreen.visible = true
		$HUD/WinnerScreen/Star/AnimationPlayer.play("star_bounce")
		$HUD/WinnerScreen/Label.text = 'Player '+last_winner.number+' wins!'
		var wiz_sprites = wizard_sprites.instance()
		wiz_sprites.use_export_vars = true
		wiz_sprites.p_number = last_winner.number
		wiz_sprites.frame = 68
		wiz_sprites.scale = Vector2(3, 3)
		wiz_sprites.position = $HUD/WinnerScreen/Position2D.position
		$HUD/WinnerScreen.add_child(wiz_sprites)
	else:
		next_round()


func _on_Button_button_up():
	g.players_in_current_game = []
	get_tree().change_scene("res://menus/start/start.tscn")
	g.new_game = false


func _on_StartingTimer_timeout():
	starting_seconds -= 1
	if starting_seconds == 0:
		for player in get_tree().get_nodes_in_group('players'):
			player.super_disabled = false
		$HUD/StartingTime.visible = false
		$StartingTimer.stop()
		$MatchTimer.start()
	else:
		$HUD/StartingTime.text = 'Starting in '+str(starting_seconds)+'...'


func _on_PressStartTimer_timeout():
	$HUD/Tutorial/presskeytostart.visible = true



