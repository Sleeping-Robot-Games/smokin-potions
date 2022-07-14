extends Node

onready var wizard = preload('res://players/wizard/wizard.tscn')
onready var bot = preload("res://players/bots/bot.tscn")

onready var match_time = get_node("HUD/MatchTime")
var seconds = 120

func _ready():
	g.connect("elements_changed", self, "handle_elements_changed")
	for player in g.players_in_current_game:
		var new_player = wizard.instance() if not player.bot else bot.instance()
		g.load_player(new_player, player.number)
		var starting_pos = get_node("Starting" + str(player.number)).global_position
		new_player.global_position = starting_pos
		$YSort.add_child(new_player)
		
	# Reset current game array?
	g.players_in_current_game = []


func handle_elements_changed(elements):
	if elements.size() == 2:
		$HUD/Element1.set_texture(load("res://pickups/runes/" + elements[0] + ".png"))
		$HUD/Element2.set_texture(load("res://pickups/runes/" + elements[1] + ".png"))
	elif elements.size() == 1:
		$HUD/Element1.set_texture(load("res://pickups/runes/" + elements[0] + ".png"))
		$HUD/Element2.texture = null
	else:
		$HUD/Element1.texture = null
		$HUD/Element2.texture = null


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
