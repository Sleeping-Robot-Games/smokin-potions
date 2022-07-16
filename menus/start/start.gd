extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if not g.new_game:
		visible = false
		get_parent().get_node("Select").visible = true
	$Sprite/AnimationPlayer.play("jiggle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_button_up():
	visible = false
	get_parent().get_node("Select").visible = true
