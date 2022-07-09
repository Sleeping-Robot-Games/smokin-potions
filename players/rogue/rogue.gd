extends KinematicBody2D

export (int) var run_speed: int = 150
export (int) var sneak_speed: int = 75
export (PackedScene) var Projectile

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var game_scene: Node = null
#onready var player_start_node: Position2D = get_node("/root/Game/PlayerStart")

var type = "player"
var inversion_count: int = 0
var slices_count: int = 4
var slices_lost: int = 0
var safe = false
var is_invulnerable = false
var is_flashing = false
var speed: int = run_speed
var velocity: Vector2 = Vector2()
var sneaking: bool = false
var inverse_ready: bool = true
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
	#last_checkpoint_pos = player_start_node.global_position
	#slices_icon.texture = load('Assets/Slices' + str(slices_count) + '.png')


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
	
	if Input.is_action_just_pressed("crouch"):
		sneaking = !sneaking
		speed = sneak_speed if sneaking else run_speed
		# g.emit_signal('sneak', sneaking)

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


func sprite_animation():
	# If X and Y both changed, Y currently takes precedence
	if x_changed:
		new_facing = x_facing
	elif y_changed:
		new_facing = y_facing
		
	var new_animation = animation
	if velocity == Vector2(0,0) and sneaking:
		new_animation = "SneakIdle"
	elif velocity == Vector2(0,0) and not sneaking:
		new_animation = "Idle"
	elif velocity != Vector2(0,0) and sneaking:
		new_animation = "Sneak"
	elif velocity != Vector2(0,0) and not sneaking:
		new_animation = "Run"
	
	if not movement_enabled and new_animation == "Run":
		new_animation = "Idle"
	elif not movement_enabled and new_animation == "Sneak":
		new_animation = "SneakIdle"
	
	if new_facing != facing or new_animation != animation:
		facing = new_facing
		animation = new_animation
		anim_player.play(animation + facing)


func _physics_process(delta):
	get_input()
	var collision = move_and_collide(velocity * delta)
	if collision:
		pass


func attacked():
	if not current_enemy:
		return
	var enemy_name = current_enemy.name.rstrip("0123456789")
	if !is_invulnerable:
		is_invulnerable = true
		play_sfx('getting_hit')
		slices_lost += 1
		#g.emit_signal('shake', 0.2, 15, 16, 0)
		#g.emit_signal('go_home', current_enemy)
		if slices_count == 1:
			# Respawn at checkpoint
			slices_count = 4
			movement_enabled = false
			game_scene.respawn()
		else:
			slices_count -= 1
			# unset layer
			set_collision_layer_bit(3, false) # player_normal
			set_collision_layer_bit(4, false)  # player_inverted
			# unset masks
			set_collision_mask_bit(6, false)  # enemy_normal
			set_collision_mask_bit(7, false)   # enemy_inverted
		
		$FlashTimer.start()
		$InvulnerabilityTimer.start()
		#slices_icon.texture = load('Assets/Slices' + str(slices_count) + '.png')


func play_sfx(name):
	var sfx_player = AudioStreamPlayer2D.new()
	sfx_player.stream = load("res://Assets/Audio/"+name+".mp3")
	sfx_player.connect("finished", sfx_player, "queue_free")
	add_child(sfx_player)
	sfx_player.play()


func pick_up_coin():
	if current_coin:
		if current_coin.type == "Coin":
			play_sfx('coin')
			game_scene.add_coin()
			current_coin.queue_free()
			current_coin = null


func _on_PickupArea_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area and area.name == 'ItemArea':
		if "Coin" in area.get_parent().type:
			current_coin = area.get_parent()
			pick_up_coin()
		if area.get_parent().type == "Watch":
			play_sfx('pick_up')
			game_scene.add_time()
			area.get_parent().queue_free()
		
	if area.name == 'SafeZoneArea':
		safe = true
		if last_checkpoint_pos != area.get_parent().get_node('Checkpoint').global_position:
			# Only play the first time they enter the checkpoint
			play_sfx('save')
			area.get_parent().float_text('Checkpoint Reached!')
		last_checkpoint_pos = area.get_parent().get_node('Checkpoint').global_position


func _on_PickupArea_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if area and area.name == 'SafeZoneArea':
		safe = false


func _on_InverseCooldown_timeout():
	inverse_ready = true


func _on_PickupArea_body_entered(body):
	#current_enemy = body
	#attacked()
	pass


func _on_PickupArea_body_exited(body):
	current_enemy = null


func _on_InvulnerabilityTimer_timeout():
	if not movement_enabled:
		global_position = last_checkpoint_pos
		movement_enabled = true
	is_invulnerable = false


func _on_FlashTimer_timeout():
	if is_invulnerable:
		if is_flashing:
			modulate = Color(1,1,1,1) # normal
		else:
			modulate = Color(1,0,0,0.5) # red
		is_flashing = !is_flashing
		$FlashTimer.start()
	else:
		modulate = Color(1,1,1,1) # normal


func _on_ProjectileTimer_timeout():
	var projectile_instance = Projectile.instance()
	add_child(projectile_instance)
	projectile_instance.look_at(get_global_mouse_position())
