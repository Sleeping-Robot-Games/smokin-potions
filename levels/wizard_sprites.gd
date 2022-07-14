extends Node2D

export (int) var frame: int = 3
export (String) var number: String = "1"

# Called when the node enters the scene tree for the first time.
func _ready():
	for sprite in get_children():
		sprite.frame = frame
	g.load_player(self, number)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
