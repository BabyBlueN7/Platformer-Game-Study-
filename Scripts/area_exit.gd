extends Area2D

func _on_body_entered(body):
	if body is PlayerController:
		print("The Player entered the Area exit!")
