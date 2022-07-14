extends Control

var overlapping_players = []


func _ready():
	$Element1.texture = null
	$Element2.texture = null
	

func make_ui_transparent():
	modulate = Color(1, 1, 1, .25)
	
func make_ui_normal():
	modulate = Color(1, 1, 1, 1)


func _on_UIArea_body_entered(body):
	if 'Bot' in body.name or 'Wizard' in body.name:
		overlapping_players.append(body)
		
	if overlapping_players.size() > 0:
		make_ui_transparent()


func _on_UIArea_body_exited(body):
	if 'Bot' in body.name or 'Wizard' in body.name:
		overlapping_players.erase(body)
	
	if overlapping_players.size() == 0:
		make_ui_normal()

