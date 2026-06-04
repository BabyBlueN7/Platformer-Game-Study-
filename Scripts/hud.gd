extends Control
class_name HUD

@export var energy_cell_label: Label
@export var portal_label : Label
@export var stopwatch_label : Label
@export var RestartButton: Button
@export var CheckpointButton: Button
@export var NextLevelButton: Button

var _jetpack_popup_token: int = 0
var time: float = 0.0
var running: bool = true

func _ready():
	if RestartButton:
		RestartButton.visible = false
	if CheckpointButton:
		CheckpointButton.visible = false
	if NextLevelButton:
		NextLevelButton.visible = false

func _process(delta):
	if running:
		time += delta
	update_stopwatch_label()

func update_stopwatch_label():
	var msec_f = fmod(time, 1) * 1000
	var sec_f = fmod(time, 60)
	var mins = int(time / 60)
	var secs = int(sec_f)
	var msecs = int(msec_f)
	stopwatch_label.text = "%02d:%02d:%03d" % [mins, secs, msecs]

func pause_timer():
	running = false

func resume_timer():
	running = true

func reset_timer():
	time = 0.0
	running = true

func update_energy_cell_label(number : int):
	energy_cell_label.text = "x " + str(number)

func portal_opened():
	portal_label.text = "Portal Opened!"

func portal_closed():
	portal_label.text = "Portal Closed... Need 3 Energy Cells"

# --- NEW COMMANDS ---

func show_restart_button():
	RestartButton.visible = true
	CheckpointButton.visible = false

func show_restart_and_checkpoint_buttons():
	RestartButton.visible = true
	CheckpointButton.visible = true

func show_next_level_button():
		NextLevelButton.visible = true
		pause_timer()

func _on_RestartButton_pressed():
	GameManager.energy_cells = 0
	GameManager.checkpoints.clear()
	GameManager.current_checkpoint = Vector2.ZERO
	update_energy_cell_label(0)
	portal_closed()
	GameManager.load_area(GameManager.current_area)    # ✅ reloads current level
	reset_timer()
	_hide_buttons()

func _on_CheckpointButton_pressed():
	if GameManager.current_checkpoint != Vector2.ZERO:
		var player = get_tree().get_first_node_in_group("player") as PlayerController
		player.global_position = GameManager.current_checkpoint
		resume_timer()
	_hide_buttons()

func _on_next_level_button_pressed():
		GameManager.next_area()
		reset_timer() 
		NextLevelButton.visible = false

func _hide_buttons():
	RestartButton.visible = false
	CheckpointButton.visible = false
	NextLevelButton.visible = false

func show_jetpack_icon():
	$JetpackIcon.visible = true

func show_jetpack_popup(text: String, duration: float = 6.0) -> void:
	_jetpack_popup_token += 1
	var my_token = _jetpack_popup_token
	$JetpackLabel.text = text
	$JetpackLabel.visible = true
	await get_tree().create_timer(duration).timeout
	if my_token == _jetpack_popup_token:
		$JetpackLabel.visible = false
