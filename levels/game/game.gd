extends Node

func _ready():
	g.connect("elements_changed", self, "handle_elements_changed")


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
