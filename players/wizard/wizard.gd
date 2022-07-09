extends KinematicBody2D

export (int) var run_speed: int = 150
export (bool) var potion_cooldown_toogle: bool = false
const potion = preload('res://potions/potion_001/potion_001.tscn')

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var game_scene: Node = null
#onready var player_start_node: Position2D = get_node("/root/Game/PlayerStart")

var type = "player"
var speed: int = run_speed
var velocity: Vector2 = Vector2()
var x_facing: String = "Right"
var x_changed: bool = false
var y_facing: String = "Up"
var y_changed: bool = false
var facing: String = "Right"
var animation: String = "Idle"
var new_facing: String = facing
var movement_enabled = true
var potion_ready = true

var x_halfway = 320
var y_halfway = 240
	

func _ready():
	speed = run_speed

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	
	if movement_enabled:
		velocity = velocity.normalized() * speed

	# store necessary information to determine which way to face player in sprite_animation()
	# x axis
	x_changed = false
	if Input.is_action_pressed("right") and Input.is_action_pressed("left"):
		x_facing = x_facing
	elif Input.is_action_pressed("right"):
		x_facing = "Right"
		x_changed = true
	elif Input.is_action_pressed("left"):
		x_facing = "Left"
		x_changed = true
	# y axis
	y_changed = false
	if Input.is_action_pressed("up") and Input.is_action_pressed("down"):
		y_facing = y_facing
	elif Input.is_action_pressed("up"):
		y_facing = "Back"
		y_changed = true
	elif Input.is_action_pressed("down"):
		y_facing = "Front"
		y_changed = true
	
	sprite_animation()
	
	if Input.is_action_just_released('place'):
		place_potion()


func sprite_animation():
	new_facing = y_facing + x_facing
	var new_animation = animation

	if velocity == Vector2(0,0):
		new_animation = "Idle"
	elif velocity != Vector2(0,0):
		new_animation = "Run"
	
	if not movement_enabled and new_animation == "Run":
		new_animation = "Idle"
	
	if new_facing != facing or new_animation != animation:
		facing = new_facing
		animation = new_animation
		anim_player.play(animation + facing)

func _physics_process(delta):
	get_input()
	move_and_slide(velocity)


func place_potion():
	if not potion_ready:
		return
	var p = potion.instance()
	var potion_position = global_position
	if facing == 'Right':
		potion_position = Vector2(global_position.x + 20, global_position.y)
	if facing == 'Left':
		potion_position = Vector2(global_position.x - 20, global_position.y)
	if facing == 'Back':
		potion_position = Vector2(global_position.x, global_position.y - 30)
	if facing == 'Front':
		potion_position = Vector2(global_position.x, global_position.y + 30)

	p.global_position = potion_position
	get_parent().add_child(p)
	but_make_it_symmetrical(p.global_position)
	
	if potion_cooldown_toogle:
		potion_ready = false
		$PotionCooldown.start()
	
	
func but_make_it_symmetrical(og_p_position):
	# Generate potion instances
	var symmetrical_potions = []
	for i in range(3):
		var symmetrical_potion = potion.instance()
		symmetrical_potion.but_symmetrical()
		symmetrical_potions.append(symmetrical_potion)

	var y_opposite = Vector2(og_p_position.x, get_viewport_rect().size.y - og_p_position.y)
	symmetrical_potions[0].global_position = y_opposite
	var x_opposite = Vector2(get_viewport_rect().size.x - og_p_position.x, og_p_position.y)
	symmetrical_potions[1].global_position = x_opposite
	var direct_opposite = Vector2(get_viewport_rect().size.x - og_p_position.x, get_viewport_rect().size.y - og_p_position.y)
	symmetrical_potions[2].global_position = direct_opposite
	
	# Lay them pots
	for p in symmetrical_potions:
		get_parent().add_child(p)


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
	pass


func _on_PickupArea_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	pass


func _on_PickupArea_body_entered(body):
	pass


func _on_PickupArea_body_exited(body):
	pass



