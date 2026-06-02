extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.pickup_jetpack(global_position)
		var audio_manager = get_tree().get_first_node_in_group("audio_manager") as AudioManager
		audio_manager.play_jetpack()

		queue_free()   # remove pickup after collected
