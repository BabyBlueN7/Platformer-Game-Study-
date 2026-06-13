extends CharacterBody2D
class_name PlayerController

@export var speed: float = 10.0
@export var jump_power: float = 10.0
@export var camera : Camera2D
@export var gravity: float = 980.0   # custom gravity for the character
@export var jump_buffer_time: float = 0.1
@export var coyote_time: float = 0.1

var speed_multiplier = 30.0
var jump_multiplier = -30.0
var direction = 0

var jump_buffer_timer: float = 0.0
var coyote_timer: float = 0.0
var was_on_floor = true
var hud: HUD
var double_jump_used: bool = false
var is_alive: bool = true
var _saved_camera_limit_bottom: int = -1


func _ready():
	hud = get_tree().get_first_node_in_group("hud")

func resurrection():
	is_alive = true
	velocity = Vector2.ZERO
	# reset any state that should be cleared on respawn
	double_jump_used = false
	was_on_floor = is_on_floor()
	# restore camera limits and smoothing
	if camera:
		if _saved_camera_limit_bottom != -1:
			camera.limit_bottom = _saved_camera_limit_bottom
			_saved_camera_limit_bottom = -1
		camera.reset_smoothing()
	# ensure processing is enabled
	set_physics_process(true)
	set_process(true)
	# debug: confirm resurrection ran
	print("resurrection called — is_alive:", is_alive, "velocity:", velocity)


func _input(event):
	if not is_alive:
		return
	# Handle jump input buffering
	if event.is_action_pressed("JUMP"):
		jump_buffer_timer = jump_buffer_time


	# Handle down jump
	if event.is_action_pressed("DOWN"):
		set_collision_mask_value(10, false)
	else:
		set_collision_mask_value(10, true)

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Update timers
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta
	if coyote_timer > 0.0:
		coyote_timer -= delta

	# Reset coyote timer when grounded
	if is_on_floor():
		coyote_timer = coyote_time
		double_jump_used = false   # ✅ reset when touching ground

	# Handle jump with buffer + coyote time
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_power * jump_multiplier
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		var audio_manager = get_tree().get_first_node_in_group("audio_manager") as AudioManager
		audio_manager.play_jump()

# Double Jump
	elif jump_buffer_timer > 0.0 and not is_on_floor() and GameManager.has_jetpack and not double_jump_used:
		velocity.y = jump_power * jump_multiplier
		jump_buffer_timer = 0.0
		double_jump_used = true
		var audio_manager = get_tree().get_first_node_in_group("audio_manager") as AudioManager
		audio_manager.play_jetpack()
		# 🔥 Jetpack effect trigger
		$JetpackEffect.emitting = true
		$JetpackEffect.restart()
		$JetpackTimer.start()


	# Horizontal movement
	direction = Input.get_axis("LEFT", "RIGHT")
	if direction:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	move_and_slide()

	# Walking sound logic
	var audio_manager = get_tree().get_first_node_in_group("audio_manager") as AudioManager
	if audio_manager:
		if is_on_floor() and abs(velocity.x) > 0.1:
			audio_manager.start_walking()
		else:
			audio_manager.stop_walking()

 	# Landing sound trigger
	if not was_on_floor and is_on_floor() and Engine.get_frames_drawn() > 1:
		audio_manager.play_land()
	was_on_floor = is_on_floor()


func teleport_to_location(new_location):
	position = new_location
	camera.reset_smoothing()

func die():
	is_alive = false
	# Clamp camera so it won't move further down and disable smoothing for a stable frame
	if camera:
		_saved_camera_limit_bottom = camera.limit_bottom
		# clamp bottom to current camera Y so it won't reveal empty area below
		camera.limit_bottom = int(camera.global_position.y)
	hud.pause_timer()   # pause timer when death popup showss
	# Example: respawn at start position
	if GameManager.energy_cells == 0:
		hud.show_restart_button()
	else:
		hud.show_restart_and_checkpoint_buttons()

func _on_JetpackTimer_timeout():
	$JetpackEffect.emitting = false
