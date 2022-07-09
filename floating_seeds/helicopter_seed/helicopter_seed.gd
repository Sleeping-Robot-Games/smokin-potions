extends KinematicBody2D

var move_speed = 50
var shadow_offset = 80
var velocity = Vector2.ZERO
var spawn = Vector2.ZERO
var destination = Vector2.ZERO
onready var plants = get_node("/root/Game/YSort/Plants")
var test_plant = preload("res://plants/test_plant/test_plant.tscn")


func _ready():
	$AnimationPlayer.play("falling")
	$Shadow.modulate.a = 0.0


func _physics_process(delta):
	# move towards destination
	velocity = global_position.direction_to(destination) * move_speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		pass
	
	# determine shadow offset and opacity depending on distance to destination
	var total_distance = spawn.distance_to(destination)
	# prevent division by 0 errors
	if total_distance <= 0:
		total_distance = 1
	var remaining_distance = global_position.distance_to(destination)
	var progress_normalized = 1 - clamp(0, remaining_distance / total_distance, 1)
	$Shadow.offset.y = (1 - progress_normalized) * shadow_offset
	$Shadow.modulate.a = progress_normalized
	
	# if within 1 pixel of destination, play dust cloud animation
	if remaining_distance <= 1:
		$AnimationPlayer.play("dust_cloud")


func _on_AnimationPlayer_animation_finished(anim_name):
	# after dust cloud finishes, turn into a grounded seed or sapling
	if anim_name == "dust_cloud":
		print("dust_cloud")
		var seed_instance = test_plant.instance()
		seed_instance.global_position = global_position
		plants.add_child(seed_instance)
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var spawn_type = rng.randi_range(0, 2)
		# grounded seed
		if spawn_type <= 1:
			print("spawn_seed()")
			seed_instance.spawn_seed()
		else:
			print("spawn_sapling()")
			seed_instance.spawn_sapling()
		queue_free()
		
