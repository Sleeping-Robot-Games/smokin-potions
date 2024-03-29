extends RayCast2D

export var cast_speed := 7000.0
export var max_length := 100
export var growth_time := 0.1

onready var casting_particles := $CastingParticles
onready var collision_particles := $CollisionParticles
onready var beam_particles := $BeamParticles
onready var fill := $FillLine
onready var tween := $Tween
onready var line_width: float = fill.width

var is_casting := false setget set_is_casting
var use_portal = false

var last_wiz

var nearby_players = []
var nearby_breakables = []

# Used for laser circular movement
var d := 0.0
var radius := 50.0
var speed := 1.0
onready var center = Vector2(position.x, position.y - radius)

func _process(delta: float) -> void:
	d += delta
	position = Vector2(sin(d * speed) * radius,cos(d * speed) * radius) + center


func _ready() -> void:
	if not use_portal:
		g.play_sfx(self, 'laser_beam')
	set_physics_process(false)
	fill.points[1] = Vector2.ZERO
	self.is_casting = true
	$StopTimer.start()


func _physics_process(delta: float) -> void:
	cast_to = (cast_to + Vector2.RIGHT * cast_speed * delta).clamped(max_length)
	cast_beam()


func set_is_casting(cast: bool) -> void:
	is_casting = cast

	if is_casting:
		cast_to = Vector2.ZERO
		fill.points[1] = cast_to
		appear()
	else:
		collision_particles.emitting = false
		disappear()

	set_physics_process(is_casting)
	beam_particles.emitting = is_casting
	casting_particles.emitting = is_casting


func cast_beam() -> void:
	var cast_point := cast_to

	# Required, the raycast's collisions update one frame after moving otherwise, making the laser
	# overshoot the collision point.
	force_raycast_update()
	if is_colliding():
		var collider = get_collider()
		# TODO: apply damage while splashing laser off player/bot instead of instantly
#		if nearby_players.has(collider) and collider.global_position.distance_to(global_position) > max_length - 20:
#			cast_point = to_local(get_collision_point())
#			collision_particles.process_material.direction = Vector3(
#				get_collision_normal().x, get_collision_normal().y, 0
#			)
#			collider.take_dmg(1, self)
				
		if nearby_breakables.has(collider):
			tween.interpolate_callback(self, .5, "break", collider)
			tween.start()
			
	collision_particles.emitting = true
	fill.points[1] = cast_point
	collision_particles.position = cast_point
	beam_particles.position = cast_point * 0.5
	beam_particles.process_material.emission_box_extents.x = cast_point.length() * 0.5


func break(breakable):
	if nearby_breakables.has(breakable):
		breakable.break()


func appear() -> void:
	if tween.is_active():
		tween.stop_all()
	tween.interpolate_property(fill, "width", 0, line_width, growth_time * 2)
	tween.start()


func disappear() -> void:
	if tween.is_active():
		tween.stop_all()
	tween.interpolate_property(fill, "width", fill.width, 0, growth_time)
	tween.start()


func _on_Area2D_body_entered(body):
	if g.is_player(body):
		nearby_players.append(body)
		body.take_dmg(1, self)
		


func _on_Area2D_body_exited(body):
	if g.is_player(body):
		nearby_players.erase(body)


func _on_Area2D_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if g.is_breakable(area):
		nearby_breakables.append(area.get_parent())


func _on_Area2D_area_shape_exited(_area_rid, area, _area_shape_index, _local_shape_index):
	if g.is_breakable(area):
		nearby_breakables.erase(area.get_parent())


func _on_StopTimer_timeout():
	self.is_casting = false
	$RemoveTimer.start()


func _on_RemoveTimer_timeout():
	queue_free()


func _on_BreakableTimer_timeout():
	pass # Replace with function body.
