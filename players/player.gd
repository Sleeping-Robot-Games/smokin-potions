extends KinematicBody2D

export (int) var run_speed: int = 150
export (bool) var potion_cooldown_toogle: bool = false
export (bool) var disabled: bool = false

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var game_scene: Node = null

const KICK_FORCE = 400
const DIAG_KICK_FORCE = 200

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

func _ready():
	speed = run_speed


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
