extends Control
# warning-ignore-all:return_value_discarded

var overlapping_bodies = []
var player_number
var health
var freeze_ui_change = false

func play_star_animation(player_num, wins):
	make_ui_normal()
	freeze_ui_change = true
	if player_num == "1":
		var star_anim: Animation = $AnimationPlayer.get_animation('star'+wins) 
		star_anim.track_set_key_value(1, 0, Vector2(320, 240)) # set beginning
		star_anim.track_set_key_value(1, 1, Vector2(182, 111)) # set mid
		star_anim.track_set_key_value(1, 2, Vector2(182, 111)) # set mid
		$AnimationPlayer.play("star"+wins)
	elif player_num == "2":
		var star_anim: Animation = $AnimationPlayer.get_animation('star'+wins) 
		star_anim.track_set_key_value(1, 0, Vector2(-224, 240)) # set beginning
		star_anim.track_set_key_value(1, 1, Vector2(-352, 111)) # set mid
		star_anim.track_set_key_value(1, 2, Vector2(-352, 111)) # set mid
		$AnimationPlayer.play("star"+wins)
	elif player_num == "3":
		var star_anim: Animation = $AnimationPlayer.get_animation('star'+wins) 
		star_anim.track_set_key_value(1, 0, Vector2(320, -180)) # set beginning
		star_anim.track_set_key_value(1, 1, Vector2(191, -339)) # set mid
		star_anim.track_set_key_value(1, 2, Vector2(191, -339)) # set mid
		$AnimationPlayer.play("star"+wins)
	elif player_num == "4":
		var star_anim: Animation = $AnimationPlayer.get_animation('star'+wins) 
		star_anim.track_set_key_value(1, 0, Vector2(-224, -180)) # set beginning
		star_anim.track_set_key_value(1, 1, Vector2(-352, -352)) # set mid
		star_anim.track_set_key_value(1, 2, Vector2(-352, -352)) # set mid
		$AnimationPlayer.play("star"+wins)

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
		rect_position = Vector2(1, 432)
	else:
		rect_position = Vector2(544, 432)


func make_ui_transparent():
	modulate = Color(1, 1, 1, .35)
	
func make_ui_normal():
	modulate = Color(1, 1, 1, 1)
	
func handle_heath_changed(_health, damage, number):
	if player_number == number:
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
	if freeze_ui_change:
		return
		
	if 'Bot' in body.name or 'Wizard' in body.name or 'Potion' in body.name:
		overlapping_bodies.append(body)
		
	if overlapping_bodies.size() > 0:
		make_ui_transparent()


func _on_UIArea_body_exited(body):
	if 'Bot' in body.name or 'Wizard' in body.name or 'Potion' in body.name:
		overlapping_bodies.erase(body)
	
	if overlapping_bodies.size() == 0:
		make_ui_normal()


func _on_AnimationPlayer_animation_finished(_anim_name):
	change_health_ui()
	freeze_ui_change = false
