extends KinematicBody2D

var rng = RandomNumberGenerator.new()

export (bool) var potion_cooldown_toogle: bool = false
export (bool) var disabled: bool = false
export (bool) var super_disabled: bool = false
export (bool) var dead_disabled: bool = false

onready var anim_player: AnimationPlayer = $AnimationPlayer

const KICK_FORCE = 400
const DIAG_KICK_FORCE = 200
const NORMAL_SPEED = 150
const HUMUNGO_SPEED = 75
const TEENY_SPEED = 250


var number = "1"
var health = 2
var speed: int = NORMAL_SPEED
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
var nearby_potions = []
var holding_potion: RigidBody2D
var frozen = false
var ghost = false
var dead = false
var invulnerable = false
var symmetrical = false
var potion_drop_distance = 10
var rune_drop_distance = 30
var dropkick_potion = null
var dropkick_velocity = Vector2(1, 0)
var diag_kick_buffer = 5
var diag_kick_frames = []
var affinity = null

var controller_num = "kb"

const rune_scene = preload('res://pickups/runes/rune.tscn')

func _ready():
	var input_device = g.player_input_devices["p"+number]
	if input_device and input_device.left(4) == "joy_":
		controller_num = input_device.substr(4)
	
	add_to_group("players")
	ready()


func ready():
	pass


func place_potion(mixed = false):
	if not potion_ready or ghost:
		return
	if mixed and elements.size() == 0:
		return
	var p = g.get_potion_scene(elements if mixed else []).instance()
	p.global_position = Vector2(global_position.x, global_position.y + potion_drop_distance)
	p.parent_player = self
	get_parent().call_deferred('add_child', p)
	dropkick_potion = p
	if symmetrical:
		p.but_make_it_symmetrical(elements)
	
	# Clear elements after mixed potion use
	if mixed:
		elements = []
		if affinity:
			elements.push_front(affinity)
	g.emit_signal('elements_changed', elements, number)
	
	if potion_cooldown_toogle:
		potion_ready = false
		$PotionCooldown.start()


func _on_PotionCooldown_timeout():
	potion_ready = true


func take_dmg(dmg, potion = null):
	if ghost or dead or super_disabled:
		return
	
	if invulnerable:
		return
	
	if holding_potion and weakref(holding_potion).get_ref():
		holding_potion.drop_potion()
		holding_potion = null
		g.load_normal_assets(self, number)
		
	health -= dmg
	g.emit_signal('health_changed', health, true, number)
	
	if health > 0:
		g.play_random_sfx(self, 'hurt')
		anim_player.play('Hurt'+y_facing+x_facing)
		modulate = Color(1, .25, .25, 1)
		$HurtTimer.start()
		$InvulnerableTimer.start()
		invulnerable = true
		disabled = true
		$FloatTextManager.float_text("-"+str(dmg)+" HP", Color(1,0,0,1))
		
	if health <= 0:
		g.play_random_sfx(self, 'dying')
		anim_player.play('Death'+y_facing+x_facing)
		dead = true
		dead_disabled = true
		$DeathTimer.start()
		if potion and potion.last_wiz and potion.last_wiz.ghost and potion.last_wiz != self:
			potion.last_wiz.revive()
			g.emit_signal("player_revive", potion.last_wiz)
		g.emit_signal("player_death", self)


func freeze():
	frozen = true
	$FrozenFx.visible = true
	$FrozenNode/FrozenSprite.visible = true
	g.play_sfx(self, 'player_freeze')
	anim_player.stop(false)
	$FrozenTimer.start()


func _on_FrozenTimer_timeout():
	frozen = false
	$FrozenFx.visible = false
	$FrozenNode/FrozenSprite.visible = false
	anim_player.play()


func revive(hp = 1):
	## TODO: Make a revive sound
	health = hp
	g.emit_signal("player_revive", self)
	g.emit_signal('health_changed', health, false, number)
	$GhostParticles.visible = false
	$GhostParticles.emitting = false
	ghost = false
	dead = false
	modulate = Color(1, 1, 1, 1)


func heal(hp):
	health += hp
	g.emit_signal('health_changed', health, false, number)


func get_stunned():
	if dead:
		return
	g.play_sfx(self, 'character_stunned')
	disabled = true
	$StunnedTimer.start()
	anim_player.play('Daze'+y_facing+x_facing)


func _on_HurtTimer_timeout():
	modulate = Color(1, 1, 1, 1)
	disabled = false

func _on_InvulnerableTimer_timeout():
	invulnerable = false


func _on_StunnedTimer_timeout():
	disabled = false
	anim_player.play("Idle"+y_facing+x_facing)


func _on_DeathTimer_timeout():
	anim_player.play('Idle'+y_facing+x_facing)
	ghost = true
	dead_disabled = false
	$GhostParticles.emitting = true
	modulate = Color(1, 1, 1, .25)


func _on_PickupArea_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if area and weakref(area).get_ref() and 'Rune' in area.get_parent().name and not ghost:
		var rune = area.get_parent()
		# if already have 2 runes, drop the 2nd to make room
		if elements.size() == 2:
			var rune_instance = rune_scene.instance()
			var rune_pos = global_position
			if cardinal_facing == "Left":
				rune_pos.x += rune_drop_distance
			elif cardinal_facing == "Right":
				rune_pos.x -= rune_drop_distance
			elif cardinal_facing == "Back":
				rune_pos.y += rune_drop_distance + 5
			elif cardinal_facing == "Front":
				rune_pos.y -= rune_drop_distance
			rune_instance.global_position = rune_pos
			get_parent().call_deferred('add_child', rune_instance)
			rune_instance.set_type(elements[1])
			elements.remove(1)
			
		var element_color_map = {
			'earth': Color("#256830"),
			'arcane': Color("#c32379"),
			'ice': Color("#39aac8"),
			'fire': Color("#c35723")
		}
		$FloatTextManager.float_text(rune.element, element_color_map[rune.element])
		elements.push_front(rune.element)
		g.emit_signal('elements_changed', elements, number)
		g.play_sfx(self, 'rune_grab', 5)
		rune.cleanup()
	elif 'Scroll' in area.get_parent().name and not ghost:
		$ScrollTimer.stop()
		reset_scroll_magic()
		var scroll = area.get_parent()
		$FloatTextManager.float_text(scroll.label_text, Color(1,1,1,1))
		if scroll.magic == 'humungo':
			humungo()
		elif scroll.magic == 'tinyboi':
			tinyboi()
		elif scroll.magic == 'potionparty':
			start_the_party()
		elif scroll.magic == 'heal' and health == 1:
			heal(1)
		elif scroll.magic == 'symmetry':
			you_know_im_good_for_that_jam_theme_son()
		rng.randomize()
		g.play_random_sfx(self, 'scroll_grab', 4, 15)
		scroll.cleanup()
		$ScrollTimer.start()


func humungo():
	speed = HUMUNGO_SPEED
	scale = Vector2(3,3)
	potion_drop_distance = 40
	rune_drop_distance = 60


func tinyboi():
	speed = TEENY_SPEED
	scale = Vector2(.75, .75)


func start_the_party():
	get_node('/root/Game/PotionParty').start()


func you_know_im_good_for_that_jam_theme_son():
	# WILD JAM #47 DON'T YOU FORGET IT, BABY
	var new_timer = Timer.new()
	new_timer.wait_time = 5
	new_timer.autostart = true
	new_timer.connect("timeout", self, "_on_symmetrical_timeout")
	add_child(new_timer)
	
	symmetrical = true
	
func _on_symmetrical_timeout():
	symmetrical = false

func reset_animation():
	if number == "1" or number == "3":
		anim_player.play('IdleFrontRight')
	if number == "2" or number == "4":
		anim_player.play('IdleFrontLeft')

func reset_scroll_magic():
	speed = NORMAL_SPEED
	scale = Vector2(1.5, 1.5)
	potion_drop_distance = 10
	rune_drop_distance = 30


func _on_ScrollTimer_timeout():
	reset_scroll_magic()
	get_node('/root/Game/PotionParty').stop()


func _on_AnimationPlayer_animation_finished(anim_name):
	if "Kick" in anim_name:
		if kicking_potion and weakref(kicking_potion).get_ref():
			kicking_potion.kick(kicking_impulse, self)
			g.play_sfx(self, 'kicking_potion')
		kicking_potion = null
		kicking_impulse = Vector2.ZERO
		anim_player.play("Idle"+y_facing+x_facing)
	 
	if "Throw" in anim_name or 'Hurt' in anim_name:
		anim_player.play("Idle"+y_facing+x_facing)


func _on_BombPickupArea_area_entered(area):
	if area and weakref(area).get_ref() and area.name == 'PotionPickupArea' and nearby_potions.find(area.get_parent()) == -1 and !area.get_parent().potion_daddy:
		var potion = area.get_parent()
		nearby_potions.append(potion)


func _on_BombPickupArea_area_exited(area):
	if area and weakref(area).get_ref() and area.name == 'PotionPickupArea' and nearby_potions.find(area.get_parent()) != -1:
		var potion = area.get_parent()
		nearby_potions.erase(potion)
