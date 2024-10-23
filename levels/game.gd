extends Node
# warning-ignore-all:return_value_discarded

var rng = RandomNumberGenerator.new()

onready var wizard = preload('res://players/wizard/wizard.tscn')
onready var bot = preload("res://players/bots/bot.tscn")
onready var ui = preload('res://levels/player_ui.tscn')
onready var breakable = preload('res://levels/breakable.tscn')
onready var wizard_sprites = preload('res://levels/wizard_sprites.tscn')
onready var potion_shooter = preload('res://levels/potion_shooter.tscn')

onready var match_time = get_node("HUD/MatchTime")
var seconds = 90
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
	
	## USED FOR DEBUGGING ##
#	if g.players_in_current_game.size() == 0:
#		g.players_in_current_game = [
#			{'number': '1', 'bot': false},
#			{'number': '2', 'bot': true},
#			{'number': '3', 'bot': true},
#			{'number': '4', 'bot': true},
#		]

	for player in g.players_in_current_game:
		add_player_to_game(player)
	
	if not g.new_game:
		tutorial_visible(false)
		start_game()
	else:
		for p in get_tree().get_nodes_in_group('player_ui'):
			p.visible = false
		tutorial_visible(true)


func _input(event):
	if reading_controls and (event is InputEventKey or event is InputEventJoypadButton):
		for p in get_tree().get_nodes_in_group('player_ui'):
			p.visible = true
		tutorial_visible(false)
		start_game()
		reading_controls = false

func start_game():
	starting_seconds = 3
	$StartingTimer.start()
	$HUD/StartingTime.visible = true
	$HUD/StartingTime.text = "Starting in 3..."
	$Music.volume_db = -15
	if g.level_selected == "rock_garden":
		$Music.stream = load('res://sfx/battle_intro_1.mp3')
	else:
		$Music.stream = load('res://sfx/battle_intro_2.mp3')
	$Music.connect("finished", self, "_play_battle_music")
	$Music.play()

# synchronize button animations when toggling tutorial visibility
func tutorial_visible(show = true):
	for key in $HUD/Tutorial/Label.get_children():
		if key.get_class() == "AnimatedSprite":
			key.frame = 0
			key.playing = show
	$HUD/Tutorial.visible = show

func _play_battle_music():
	if g.level_selected == "rock_garden":
		$Music.volume_db = -15
		$Music.stream = load('res://sfx/battle_bgm.ogg')
	else:
		$Music.volume_db = 0
		$Music.stream = load('res://sfx/battle_bgm2.mp3')
	$Music.play()

func add_player_to_game(player):
	# init internal player dirs based on starting pos.
	## mostly needed if player immediately dropkicks before moving...
	var init_dir = {
		"1": {
			"x_facing": "Right",
			"y_facing": "Front",
			"dropkick_velocity": Vector2(0, 1)
		},
		"2": {
			"x_facing": "Left",
			"y_facing": "Front",
			"dropkick_velocity": Vector2(0, 1)
		},
		"3": {
			"x_facing": "Right",
			"y_facing": "Back",
			"dropkick_velocity": Vector2(0, -1)
		},
		"4": {
			"x_facing": "Left",
			"y_facing": "Back",
			"dropkick_velocity": Vector2(0, -1)
		},
	}
	
	# Adds player to game
	var new_player = wizard.instance() if not player.bot else bot.instance()
	current_players.append(new_player)
	win_state[player.number] = 0
	new_player.number = player.number
	g.load_player(new_player, player.number)
	var starting_pos = get_node("Starting" + str(player.number)).global_position
	new_player.global_position = starting_pos
	new_player.x_facing = init_dir[new_player.number]["x_facing"]
	new_player.y_facing = init_dir[new_player.number]["y_facing"]
	new_player.dropkick_velocity = init_dir[new_player.number]["dropkick_velocity"]
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
	$SuddenDeathEffectTimer.stop()
	seconds = 90
	for player in current_players:
		var starting_pos = get_node("Starting" + str(player.number)).global_position
		player.global_position = starting_pos
		player.revive(2)
		player.elements = []
		player.reset_animation()
		g.load_normal_assets(player, player.number)
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
			$SuddenDeathEffectTimer.start()
			g.play_sfx(self, 'overtime_bell')
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
		for p in get_tree().get_nodes_in_group('player_ui'):
			p.visible = false
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
		$Music.stream = load('res://sfx/credits.mp3')
		$Music.play()
		for i in g.player_input_devices:
			if g.player_input_devices[i] != null and 'joy' in g.player_input_devices[i]:
				g.create_cursor(int(i.substr(1,1)), $HUD/WinnerScreen)
	else:
		next_round()


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
	

func _on_SuddenDeathEffectTimer_timeout():
	if g.level_selected == 'wizard_tower':	
		for d in get_tree().get_nodes_in_group('durables'):
			if d.num != '005':
				d.fire_the_lasers()
	else:
		potion_party()


func potion_party():
	var random_potion = g.get_random_potion_scene()
	var new_potion_shooter = potion_shooter.instance()
	## get random coord
	var screenSize = get_viewport().get_visible_rect().size
	var rndX = rng.randi_range(0, screenSize.x)
	var rndY = rng.randi_range(0, screenSize.y)
	var random_pos = Vector2(rndX, rndY)
	new_potion_shooter.global_position = random_pos
	new_potion_shooter.visible = false
	$YSort.add_child(new_potion_shooter)
	var good_to_go = new_potion_shooter.safe_zone()
	if good_to_go:
		new_potion_shooter.visible = true
		new_potion_shooter.get_node("AnimationPlayer").play('fade')
		var new_random_potion = random_potion.instance()
		new_random_potion.global_position = Vector2(random_pos.x, random_pos.y -300)
		new_random_potion.flight_target = random_pos
		new_random_potion.bombs_away = true
		new_random_potion.shooter = new_potion_shooter
		new_random_potion.get_node('CollisionShape2D').disabled = true
		$YSort.add_child(new_random_potion)
		new_random_potion.get_node('AnimationPlayer').play('drop_fade')
	else:
		new_potion_shooter.queue_free()


func _on_PotionParty_timeout():
	potion_party()


func _on_PlayAgain_pressed():
	g.players_in_current_game = []
	get_tree().change_scene("res://menus/start/start.tscn")
	g.new_game = false
