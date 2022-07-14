extends KinematicBody2D

export (int) var run_speed: int = 150
export (bool) var potion_cooldown_toogle: bool = false

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var game_scene: Node = null
#onready var player_start_node: Position2D = get_node("/root/Game/PlayerStart")

var type = "bot"
var number = '2'
var speed: int = run_speed
var velocity: Vector2 = Vector2()
var x_facing: String = "Right"
var x_changed: bool = false
var y_facing: String = "Back"
var y_changed: bool = false
var facing: String = "BackRight"
var cardinal_facing: String = "Right"
var animation: String = "Idle"
var new_facing: String = facing
var new_cardinal_facing: String = cardinal_facing
var movement_enabled = true
var potion_ready = true
var kicking_impulse = Vector2.ZERO
var kicking_potion = null
const KICK_FORCE = 200
const DIAG_KICK_FORCE = 100
var elements = ['arcane', 'arcane']


var node_target = null
var dir = Vector2.ZERO

func _ready():
	speed = run_speed


func sprite_animation():
	new_facing = y_facing + x_facing
	if x_changed:
		new_cardinal_facing = x_facing
	elif y_changed:
		new_cardinal_facing = y_facing
	
	var new_animation = animation

	if kicking_impulse != Vector2.ZERO:
		velocity = Vector2.ZERO
		new_animation = "Kick"
	elif velocity == Vector2(0,0):
		new_animation = "Idle"
	elif velocity != Vector2(0,0):
		new_animation = "Run"
	
	if not movement_enabled and new_animation == "Run":
		new_animation = "Idle"
	
	if new_facing != facing or new_animation != animation:
		facing = new_facing
		animation = new_animation
		anim_player.play(animation + facing)
	
	if new_cardinal_facing != cardinal_facing:
		cardinal_facing = new_cardinal_facing


func _physics_process(delta):
	if "Kick" in anim_player.current_animation:
		return
	var motion = dir * speed
	move_and_slide(motion)


func place_potion():
	if not potion_ready:
		return
	var p = g.get_potion_scene(elements).instance()
	
	# Places the potion in front of player
	var potion_position = global_position
	if cardinal_facing == 'Right':
		potion_position = Vector2(global_position.x + 20, global_position.y)
	if cardinal_facing == 'Left':
		potion_position = Vector2(global_position.x - 20, global_position.y)
	if cardinal_facing == 'Back':
		potion_position = Vector2(global_position.x, global_position.y - 30)
	if cardinal_facing == 'Front':
		potion_position = Vector2(global_position.x, global_position.y + 30)

	p.global_position = potion_position
	get_parent().add_child(p)
	# p.add_to_group(str(p.get_instance_id()))
	p.but_make_it_symmetrical(elements)
	
	# Clear elements after potion use
	elements = []
	g.emit_signal('elements_changed', elements)
	
	if potion_cooldown_toogle:
		potion_ready = false
		$PotionCooldown.start()


func _on_PotionCooldown_timeout():
	potion_ready = true


func play_sfx(name):
	pass
#	var sfx_player = AudioStreamPlayer2D.new()
#	sfx_player.stream = load("res://Assets/Audio/"+name+".mp3")
#	sfx_player.connect("finished", sfx_player, "queue_free")
#	add_child(sfx_player)
#	sfx_player.play()


func pick_up_coin():
	pass
#	if current_coin:
#		if current_coin.type == "Coin":
#			play_sfx('coin')
#			game_scene.add_coin()
#			current_coin.queue_free()
#			current_coin = null


func _on_PickupArea_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if 'Rune' in area.get_parent().name:
		var rune = area.get_parent()
		if elements.size() == 2:
			elements.remove(1)
		elements.push_front(rune.element)
		g.emit_signal('elements_changed', elements)
		rune.cleanup()


func _on_PickupArea_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	pass


func _on_PickupArea_body_entered(body):
	pass


func _on_PickupArea_body_exited(body):
	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if "Kick" in anim_name:
		if kicking_potion and weakref(kicking_potion).get_ref():
			kicking_potion.kick(kicking_impulse)
		kicking_potion = null
		kicking_impulse = Vector2.ZERO


func _on_ThinkTimer_timeout():
	determine_target()
	if node_target and node_target.type == 'player':
		chase_target(node_target)


func chase_target(target):
	var look = $NavRayCast
	look.cast_to = (target.global_position - global_position)
	look.force_raycast_update()
	
	# if we can see the target, chase it
	if !look.is_colliding():
		dir = look.cast_to_normalized()
	# of chase first scent we can see
	else:
		for scent in target.scent_trail:
			look.cast_to = (scent.global_position - global_position)
			look.force_raycast_update()
			
			if !look.is_colliding():
				dir = look.cast_to.normalized()
				break
	

func determine_target():
	var players = get_tree().get_nodes_in_group("players")
	players.erase(self)
	var breakables = get_tree().get_nodes_in_group("breakables")
	var nearest_player
	var nearest_breakable
	
	if players.size() > 0:
		nearest_player = nearest_target(players)
	
	#if breakables.size() > 0:
	#	nearest_ breakable = nearest_target(breakables)
	
	var nearest_targets = []
	if nearest_player:
		nearest_targets.append(nearest_player)
	if nearest_breakable:
		nearest_targets.append(nearest_breakable)
	
	node_target = nearest_target(nearest_targets)
	
	#print("node_target")
	#print(node_target)


func nearest_target(targets: Array):
	if targets.size() <= 0:
		return null
	var nearest_target = targets[0]
	for target in targets:
		var cur_target_distance = global_position.distance_to(nearest_target.global_position)
		var new_target_distance = global_position.distance_to(target.global_position)
		if new_target_distance < cur_target_distance:
			nearest_target = target
	return nearest_target


func ponder_orb():
	dir = Vector2.ZERO
	

func _on_ScentTimer_timeout():
	pass # Player only
