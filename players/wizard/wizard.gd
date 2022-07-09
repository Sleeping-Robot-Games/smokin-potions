extends KinematicBody2D

export (int) var run_speed: int = 150
export (int) var sneak_speed: int = 75
const potion = preload('res://potions/potion_001/potion_001.tscn')

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var game_scene: Node = null
#onready var player_start_node: Position2D = get_node("/root/Game/PlayerStart")

var type = "player"
var is_invulnerable = false
var speed: int = run_speed
var velocity: Vector2 = Vector2()
var last_checkpoint_pos: Vector2 = Vector2()
var x_facing: String = "Right"
var x_changed: bool = false
var y_facing: String = "Up"
var y_changed: bool = false
var facing: String = "Right"
var animation: String = "Idle"
var new_facing: String = facing
var movement_enabled = true
var current_coin = null
var current_enemy = null


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
	# If X and Y both changed, Y currently takes precedence
	if x_changed:
		new_facing = x_facing
	elif y_changed:
		new_facing = y_facing
		
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
	var collision = move_and_collide(velocity * delta)
	if collision:
		pass


func place_potion():
	var p = potion.instance()
	p.global_position = global_position
	print(get_parent().get_children())
	get_node('../../Bombs').add_child(p)


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

