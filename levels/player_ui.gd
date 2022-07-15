extends Control

var overlapping_bodies = []
var player_number

func _ready():
	player_number = name.substr(1,1)
	$Element1.texture = null
	$Element2.texture = null
	if player_number == '1':
		rect_position = Vector2(0, 0)
	elif player_number == '2':
		rect_position = Vector2(547, 0)
	elif player_number == '3':
		rect_position = Vector2(0, 439)
	else:
		rect_position = Vector2(547, 439)
	

func make_ui_transparent():
	modulate = Color(1, 1, 1, .25)
	
func make_ui_normal():
	modulate = Color(1, 1, 1, 1)


func _on_UIArea_body_entered(body):
	if 'Bot' in body.name or 'Wizard' in body.name or 'Potion' in body.name:
		overlapping_bodies.append(body)
		
	if overlapping_bodies.size() > 0:
		make_ui_transparent()


func _on_UIArea_body_exited(body):
	if 'Bot' in body.name or 'Wizard' in body.name or 'Potion' in body.name:
		overlapping_bodies.erase(body)
	
	if overlapping_bodies.size() == 0:
		make_ui_normal()

