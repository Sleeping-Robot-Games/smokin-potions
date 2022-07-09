extends Node2D

var phase: String


func spawn_seed():
	print("in test_plant.gd: spawn_seed()")
	phase = "seed"
	$Seed.visible = true


func spawn_sapling():
	print("in test_plant.gd: spawn_sapling()")
	phase = "sapling"
	$Sapling.visible = true
