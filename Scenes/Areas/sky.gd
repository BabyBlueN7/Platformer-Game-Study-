extends ParallaxLayer

func _ready() -> void:
	var tex = $Sprite2D.texture
	motion_mirroring.x = tex.get_width()
	motion_mirroring.y = 0
