extends Node

onready var wizard = preload('res://players/wizard/wizard.tscn')
onready var bot = preload("res://players/bots/bot.tscn")
onready var ui = preload('res://levels/player_ui.tscn')

onready var match_time = get_node("HUD/MatchTime")
var seconds = 120
var dead_players = []

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

func add_player_to_game(player):
	print(player)
	# Adds player to game
	var new_player = wizard.instance() if not player.bot else bot.instance()
	new_player.number = player.number
	g.load_player(new_player, player.number)
	var starting_pos = get_node("Starting" + str(player.number)).global_position
	new_player.global_position = starting_pos
	$YSort.add_child(new_player)
	
	# Creates the player's UI
	var p_ui = ui.instance()
	p_ui.name = "P"+player.number+"UI"
	$HUD.add_child(p_ui)
	

func handle_player_death(player):
	dead_players.append(player)
	if dead_players.size() == g.players_in_current_game.size() - 1:
		$HUD/GameOver.visible = true
		for p in dead_players:
			p.disabled = true

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


