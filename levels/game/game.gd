extends Node

onready var wizard = preload('res://players/wizard/wizard.tscn')
onready var bot = preload("res://players/bots/bot.tscn")

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
		$HUD/Element1.set_texture(load("res://loot/crystal/" + elements[0] + ".png"))
		$HUD/Element2.set_texture(load("res://loot/crystal/" + elements[1] + ".png"))
	elif elements.size() == 1:
		$HUD/Element1.set_texture(load("res://loot/crystal/" + elements[0] + ".png"))
		$HUD/Element2.texture = null
	else:
		$HUD/Element1.texture = null
		$HUD/Element2.texture = null
