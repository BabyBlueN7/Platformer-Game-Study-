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

func _ready():
	hud = get_tree().get_first_node_in_group("hud")

func _input(event):
	# Handle jump input buffering
	if event.is_action_pressed("JUMP"):
		jump_buffer_timer = jump_buffer_time


	# Handle down jump
	if event.is_action_pressed("DOWN"):
		set_collision_mask_value(10, false)
	else:
		set_collision_mask_value(10, true)

func _physics_process(delta: float) -> void:
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

	# Handle jump with buffer + coyote time
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_power * jump_multiplier
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		var audio_manager = get_tree().get_first_node_in_group("audio_manager") as AudioManager
		if audio_manager:
			audio_manager.play_jump()

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
	# Example: respawn at start position
	if GameManager.energy_cells == 0:
		hud.show_restart_button()
	else:
		hud.show_restart_and_checkpoint_buttons()
