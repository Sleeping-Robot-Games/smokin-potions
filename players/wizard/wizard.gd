extends KinematicBody2D

export (int) var run_speed: int = 150
export (bool) var potion_cooldown_toogle: bool = false
export (bool) var disabled: bool = false

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var game_scene: Node = null

const KICK_FORCE = 400
const DIAG_KICK_FORCE = 200

var type = "player"
var number = "1"
var health = 2
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
var elements = []
var kicking_impulse = Vector2.ZERO
var kicking_potion = null
var is_invulnerable = false
var nearby_potions = []
var holding_potion: RigidBody2D
var ghost = false

const rune_scene = preload('res://pickups/runes/rune.tscn')

const scent_scene = preload("res://players/wizard/scent/scent.tscn")
var scent_trail = []

func _ready():
	speed = run_speed

func _on_ScentTimer_timeout():
	if not disabled:
		pass
		#add_scent()


func add_scent():
	var scent = scent_scene.instance()
	scent.player = self
	scent.global_position = global_position
	get_parent().add_child(scent)
	scent_trail.push_front(scent)
	scent.visible = false


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
		
	if Input.is_action_just_released("interact"):
		if !holding_potion and nearby_potions.size() > 0:
			holding_potion = nearby_potions.pop_back()
			holding_potion.get_held(self)
			for p_ray in $PotionRays.get_children():
				p_ray.add_exception(holding_potion)
			g.load_hold_assets(self, number)
		elif holding_potion:
			holding_potion.get_thrown()
			holding_potion = null
			g.load_normal_assets(self, number)
			anim_player.play("Throw"+y_facing+x_facing)
		
		
	for p_ray in $PotionRays.get_children():
		p_ray.force_raycast_update()
	if $PotionRays/Left.is_colliding() and Input.is_action_pressed("left"):
		var collider = $PotionRays/Left.get_collider()
		kicking_impulse = Vector2(KICK_FORCE * -1, 0)
		kicking_potion = collider
	elif $PotionRays/UpperLeft.is_colliding() and (Input.is_action_pressed("up") or Input.is_action_pressed("left")):
		var collider = $PotionRays/UpperLeft.get_collider()
		kicking_impulse = Vector2(DIAG_KICK_FORCE * -1, DIAG_KICK_FORCE * -1)
		kicking_potion = collider
	elif $PotionRays/Up.is_colliding() and Input.is_action_pressed("up"):
		var collider = $PotionRays/Up.get_collider()
		kicking_impulse = Vector2(0, KICK_FORCE * -1)
		kicking_potion = collider
	elif $PotionRays/UpperRight.is_colliding() and (Input.is_action_pressed("up") or Input.is_action_pressed("right")):
		var collider = $PotionRays/UpperRight.get_collider()
		kicking_impulse = Vector2(DIAG_KICK_FORCE, DIAG_KICK_FORCE * -1)
		kicking_potion = collider
	elif $PotionRays/Right.is_colliding() and Input.is_action_pressed("right"):
		var collider = $PotionRays/Right.get_collider()
		kicking_impulse = Vector2(KICK_FORCE, 0)
		kicking_potion = collider
	elif $PotionRays/LowerRight.is_colliding() and (Input.is_action_pressed("down") or Input.is_action_pressed("right")):
		var collider = $PotionRays/LowerRight.get_collider()
		kicking_impulse = Vector2(DIAG_KICK_FORCE, DIAG_KICK_FORCE)
		kicking_potion = collider
	elif $PotionRays/Down.is_colliding() and Input.is_action_pressed("down"):
		var collider = $PotionRays/Down.get_collider()
		kicking_impulse = Vector2(0, KICK_FORCE)
		kicking_potion = collider
	elif $PotionRays/LowerLeft.is_colliding() and (Input.is_action_pressed("down") or Input.is_action_pressed("left")):
		var collider = $PotionRays/LowerLeft.get_collider()
		kicking_impulse = Vector2(DIAG_KICK_FORCE * -1, DIAG_KICK_FORCE)
		kicking_potion = collider
	else:
		kicking_impulse = Vector2.ZERO
	
	sprite_animation()
	
	if Input.is_action_just_released('place') and not ghost:
		place_potion()


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
	move_and_slide(velocity)
	if disabled or "Kick" in anim_player.current_animation:
		velocity = Vector2.ZERO
		return
	get_input()

func place_potion():
	if not potion_ready:
		return
	var p = g.get_potion_scene(elements).instance()
	p.global_position = global_position
	p.parent_player = self
	get_parent().add_child(p)
	p.but_make_it_symmetrical(elements)
	
	# Clear elements after potion use
	elements = []
	g.emit_signal('elements_changed', elements, number)
	
	if potion_cooldown_toogle:
		potion_ready = false
		$PotionCooldown.start()


func _on_PotionCooldown_timeout():
	potion_ready = true


func take_dmg(dmg):
	print(health)
	if health > 0:
		health -= dmg
		g.emit_signal('health_changed', number, health)
	if health <= 0:
		print(name + " is ghost now")
		ghost = true
		modulate = Color(1, 1, 1, .25)

func get_stunned():
	disabled = true
	$StunnedTimer.start()
	
func _on_StunnedTimer_timeout():
	disabled = false
	
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
		# if already have 2 runes, drop the 2nd to make room
		if elements.size() == 2:
			var rune_instance = rune_scene.instance()
			var rune_pos = global_position
			if cardinal_facing == "Left":
				rune_pos.x += 20
			elif cardinal_facing == "Right":
				rune_pos.x -= 20
			elif cardinal_facing == "Back":
				rune_pos.y += 25
			elif cardinal_facing == "Front":
				rune_pos.y -= 20
			rune_instance.global_position = rune_pos
			get_parent().add_child(rune_instance)
			rune_instance.set_type(elements[1])
			elements.remove(1)
		elements.push_front(rune.element)
		g.emit_signal('elements_changed', elements, number)
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
	if "Throw" in anim_name:
		anim_player.play("Idle"+y_facing+x_facing)


func _on_BombPickupArea_area_entered(area):
	if area.name == 'PotionPickupArea' and nearby_potions.find(area.get_parent()) == -1 and !area.get_parent().potion_daddy:
		var potion = area.get_parent()
		nearby_potions.append(potion)


func _on_BombPickupArea_area_exited(area):
	if area.name == 'PotionPickupArea' and nearby_potions.find(area.get_parent()) != -1:
		var potion = area.get_parent()
		nearby_potions.erase(potion)



