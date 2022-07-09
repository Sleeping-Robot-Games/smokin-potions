extends Control

export (bool) var player: int = false

onready var wizard_hat = $Wizard/Hat
onready var wizard_body = $Wizard/Body

func _ready():
	if not player:
		$Color.visible = false
		$Hat.visible = false
		$Hair.visible = false
		$Skin.visible = false
		$HairColor.visible = false
		
		$Name.text = "Bot"



func _on_Color_Left_button_up():
	pass
	#wizard_body.material.set_shader_param("palette_swap", load("res://players/wizard/Body"+data[part.name].palette_name))


func _on_Color_Right_button_up():
	pass # Replace with function body.
