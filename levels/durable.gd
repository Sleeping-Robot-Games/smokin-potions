extends Node2D

export (String) var num: String = "001"

func _ready():
	$Top.texture = load("res://levels/" + g.level_selected + "/durable/" + num + ".png")
	$Bottom.texture = load("res://levels/" + g.level_selected + "/durable/" + num + "bottom.png")
