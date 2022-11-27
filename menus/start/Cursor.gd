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
	if hovering_button != null and event.is_action_pressed('ui_press'): ## TODO: add device specific ui_press
		if hovering_button is Button:
			hovering_button.emit_signal("button_up")
		if hovering_button is CheckBox:
			hovering_button.pressed = !hovering_button.pressed


func _on_Area2D_area_entered(area):
	var button = area.get_parent()
	if button is Button and button.visible:
		if 'Box' in button.get_parent().name:
			# Only the player owned box can be edited
			if int(button.get_parent().number) == int(p_num):
				hovering_button = button
		elif button.get_parent() is Label:
			var box = button.get_parent().get_parent()
			# Only the player owned box can be edited
			if int(box.number) == int(p_num):
				hovering_button = button
		else:
			hovering_button = button


func _on_Area2D_area_exited(area):
	if area.get_parent() is Button and area.get_parent().visible:
		hovering_button = null
