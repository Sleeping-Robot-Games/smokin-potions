extends Sprite


export (int) var cursor_speed = 300

var velocity = Vector2()
var screensize
var hovering_button: Button = null
var p_num

func _ready():
	screensize = get_viewport().size
	$Label.text = "P"+str(p_num)
	if int(p_num) == 2:
		set_texture(load('res://potions/fire/fire.png'))
	if int(p_num) == 3:
		set_texture(load('res://potions/ice/ice.png'))
	if int(p_num) == 4:
		set_texture(load('res://potions/arcane/arcane.png'))


func _process(delta):
	var velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * cursor_speed

	position += velocity * delta
	position.x = clamp(position.x, 0, screensize.x)
	position.y = clamp(position.y, 0, screensize.y)


func _input(event):
	if hovering_button and event.is_action_pressed("ui_accept"):
		hovering_button.emit_signal("button_up")


func _on_Area2D_area_entered(area):
	if area.get_parent() is Button:
		hovering_button = area.get_parent()


func _on_Area2D_area_exited(area):
	if area.get_parent() is Button:
		hovering_button = null
