extends ParallaxLayer

@export var cloud_speed: float = -15.0
func _process(delta) -> void:
	motion_offset.x += cloud_speed * delta
