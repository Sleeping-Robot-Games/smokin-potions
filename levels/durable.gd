extends Node2D

const magic_missile = preload('res://potions/arcane/magic_missile/magic_missile.tscn')

var rng = RandomNumberGenerator.new()

export (String) var num: String = "001"

var particle_color_map = {
	'001': '#2ef94bbb', # arcane
	'002': '#2ef9964b', # fire
	'003': '#2e4bf964', # earth
	'004': '#2e4ddaff'  # ice
}

var mm_color_map = {
	'001': '#f94bbb',
	'002': '#f9964b', 
	'003': '#4bf964',
	'004': '#4ddaff' 
}




func _ready():
	$Top.texture = load("res://levels/" + g.level_selected + "/durable/" + num + ".png")
	$Bottom.texture = load("res://levels/" + g.level_selected + "/durable/" + num + "bottom.png")
	if g.level_selected == 'wizard_tower' and not num == '005':
		if num == '004':
			$Top.modulate = Color(1.3, 1.3, 1.3, 1)
		else:
			$Top.modulate = Color(1.5, 1.5, 1.5, 1)
		$Top/Particles2D.emitting = true
		$Top/Particles2D.visible = true
		
		$Top/Particles2D.modulate = Color(particle_color_map[num])

func fire_the_lasers():
	for _i in range(3):
		var magic_missile_instance = magic_missile.instance()
		magic_missile_instance.global_position = $Top.global_position
		if not num == '001':
			magic_missile_instance.use_portal = true
		var mat = magic_missile_instance.get_node("Sprite/Particles2D").process_material.duplicate()
		magic_missile_instance.get_node("Sprite/Particles2D").process_material = mat
		magic_missile_instance.get_node("Sprite/Particles2D").process_material.color = Color(mm_color_map[num])
		magic_missile_instance.get_node("Sprite").texture = load('res://potions/arcane/magic_missile/magic_missile_'+num+'.png')
		get_parent().add_child(magic_missile_instance)
		rng.randomize()
		magic_missile_instance.rotation_degrees = rng.randi_range(0, 360)
