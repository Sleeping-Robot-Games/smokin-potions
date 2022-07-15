extends KinematicBody2D

var rng = RandomNumberGenerator.new()

export (bool) var potion_cooldown_toogle: bool = false
export (bool) var disabled: bool = false
export (bool) var super_disabled: bool = false
export (bool) var dead_disabled: bool = false

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var game_scene: Node = get_node('/root/Game')

const KICK_FORCE = 400
const DIAG_KICK_FORCE = 200

var number = "1"
var health = 2
var speed: int = 150
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
var elements = ['ice', 'earth']
var kicking_impulse = Vector2.ZERO
var kicking_potion = null
var is_invulnerable = false
var nearby_potions = []
var holding_potion: RigidBody2D
var ghost = false
var dead = false

const rune_scene = preload('res://pickups/runes/rune.tscn')

func _ready():
	add_to_group("players")
	ready();

func ready():
	pass

func place_potion():
	if not potion_ready or ghost:
		return
	var p = g.get_potion_scene(elements).instance()
	p.global_position = Vector2(global_position.x, global_position.y + 10)
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


func take_dmg(dmg, potion):
	if ghost or dead or super_disabled:
		return
	
	if holding_potion and weakref(holding_potion).get_ref():
		holding_potion.drop_potion()
		holding_potion = null
		g.load_normal_assets(self, number)
		
	health -= dmg
	g.emit_signal('health_changed', health, true, number)
	
	if health > 0:
		play_sfx('hurt')
		anim_player.play('Hurt'+y_facing+x_facing)
		modulate = Color(1, .25, .25, 1)
		$HurtTimer.start()
		disabled = true
		$FloatTextManager.float_text("-"+str(dmg)+" HP", Color(1,0,0,1))
		
	if health <= 0:
		play_sfx('dying')
		g.emit_signal("player_death", self)
		anim_player.play('Death'+y_facing+x_facing)
		dead = true
		dead_disabled = true
		$DeathTimer.start()
		if potion.last_wiz and potion.last_wiz.ghost and potion.last_wiz != self:
			print('revived')
			potion.last_wiz.revive()
			g.emit_signal("player_revive", potion.last_wiz)
			
func revive(hp = 1):
	health = hp
	g.emit_signal("player_revive", self)
	g.emit_signal('health_changed', health, false, number)
	ghost = false
	dead = false
	modulate = Color(1, 1, 1, 1)

func get_stunned():
	if dead:
		return

	disabled = true
	$StunnedTimer.start()
	anim_player.play('Daze'+y_facing+x_facing)
	
	
func _on_HurtTimer_timeout():
	modulate = Color(1, 1, 1, 1)
	disabled = false


func _on_StunnedTimer_timeout():
	disabled = false
	anim_player.play("Idle"+y_facing+x_facing)


func _on_DeathTimer_timeout():
	anim_player.play('Idle'+y_facing+x_facing)
	ghost = true
	dead_disabled = false
	modulate = Color(1, 1, 1, .25)


func _on_PickupArea_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if 'Rune' in area.get_parent().name and not ghost:
		var rune = area.get_parent()
		# if already have 2 runes, drop the 2nd to make room
		if elements.size() == 2:
			var rune_instance = rune_scene.instance()
			var rune_pos = global_position
			if cardinal_facing == "Left":
				rune_pos.x += 30
			elif cardinal_facing == "Right":
				rune_pos.x -= 30
			elif cardinal_facing == "Back":
				rune_pos.y += 35
			elif cardinal_facing == "Front":
				rune_pos.y -= 30
			rune_instance.global_position = rune_pos
			get_parent().add_child(rune_instance)
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
		rune.cleanup()


func _on_AnimationPlayer_animation_finished(anim_name):
	if "Kick" in anim_name:
		if kicking_potion and weakref(kicking_potion).get_ref():
			kicking_potion.kick(kicking_impulse, self)
		kicking_potion = null
		kicking_impulse = Vector2.ZERO
	if "Throw" in anim_name or 'Hurt' in anim_name:
		anim_player.play("Idle"+y_facing+x_facing)


func _on_BombPickupArea_area_entered(area):
	if area.name == 'PotionPickupArea' and nearby_potions.find(area.get_parent()) == -1 and !area.get_parent().potion_daddy:
		var potion = area.get_parent()
		nearby_potions.append(potion)


func _on_BombPickupArea_area_exited(area):
	if area.name == 'PotionPickupArea' and nearby_potions.find(area.get_parent()) != -1:
		var potion = area.get_parent()
		nearby_potions.erase(potion)
		
		
func play_sfx(name):
	var sfx_player = AudioStreamPlayer2D.new()
	rng.randomize()
	var track_num = rng.randi_range(1, 5)
	print(track_num)
	sfx_player.stream = load('res://sfx/'+name+'_'+str(track_num)+'.ogg')
	sfx_player.connect("finished", sfx_player, "queue_free")
	add_child(sfx_player)
	sfx_player.play()
