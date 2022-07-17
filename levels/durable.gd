extends Node2D

export (String) var num: String = "001"

var particle_color_map = {
	'001': '#2ef94bbb',
	'002': '#2ef9964b',
	'003': '#2e4bf964',
	'004': '#2e4ddaff'
}

func _ready():
	$Top.texture = load("res://levels/" + g.level_selected + "/durable/" + num + ".png")
	$Bottom.texture = load("res://levels/" + g.level_selected + "/durable/" + num + "bottom.png")
	if g.level_selected == 'wizard_tower' and not num == '005':
		if num == '004':
			$Top.modulate = Color(1.3, 1.3, 1.3, 1)
		else:
			$Top.modulate = Color(1.5, 1.5, 1.5, 1)
		$Top/Particles2D.emitting = true
		$Top/Particles2D.visible = true
		
		$Top/Particles2D.modulate = Color(particle_color_map[num])
