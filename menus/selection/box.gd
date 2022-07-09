extends Control

export (bool) var player: int = false

func _ready():
	if not player:
		$Color.visible = false
		$Hat.visible = false
		$Hair.visible = false
		$Skin.visible = false
		$HairColor.visible = false
		
		$Name.text = "Bot"

