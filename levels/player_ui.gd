extends Control

var overlapping_bodies = []
var player_number
var health

func _ready():
	g.connect("health_changed", self, "handle_heath_changed")
	
	player_number = name.substr(1,1)
	$Element1.texture = null
	$Element2.texture = null
	if player_number == '1':
		rect_position = Vector2(1, 1)
	elif player_number == '2':
		rect_position = Vector2(544, 1)
	elif player_number == '3':
		rect_position = Vector2(1, 435)
	else:
		rect_position = Vector2(544, 435)


func make_ui_transparent():
	modulate = Color(1, 1, 1, .35)
	
func make_ui_normal():
	modulate = Color(1, 1, 1, 1)
	
func handle_heath_changed(_health, damage):
	health = _health
	if damage:
		if health == 1:
			$AnimationPlayer.play("heartshake2")
		elif health == 0:
			$AnimationPlayer.play("heartshake1")
	else:
		change_health_ui()
	
func change_health_ui():
	if health == 2:
		$Health1.set_texture(load("res://pickups/heart.png"))
		$Health2.set_texture(load("res://pickups/heart.png"))
	elif health == 1:
		$Health1.set_texture(load("res://pickups/heart.png"))
		$Health2.texture = null
	else:
		$Health1.texture = null
		$Health2.texture = null

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


func _on_AnimationPlayer_animation_finished(anim_name):
	change_health_ui()
