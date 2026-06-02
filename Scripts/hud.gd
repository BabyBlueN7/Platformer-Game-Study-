extends Control
class_name HUD

@export var energy_cell_label: Label
@export var portal_label : Label
@export var stopwatch_label : Label
@export var RestartButton: Button
@export var CheckpointButton: Button

var stopwatch : stopwatch

func _ready():
	stopwatch = get_tree().get_first_node_in_group("stopwatch")
	RestartButton.visible = false
	CheckpointButton.visible = false

func _process(delta):
	update_stopwatch_label()

func update_stopwatch_label():
	stopwatch_label.text = stopwatch.time_to_string()

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

func _on_RestartButton_pressed():
	GameManager.energy_cells = 0
	GameManager.checkpoints.clear()
	GameManager.current_checkpoint = Vector2.ZERO
	update_energy_cell_label(0)
	portal_closed()
	GameManager.load_area(GameManager.current_area)    # ✅ reloads current level
	_hide_buttons()

func _on_CheckpointButton_pressed():
	if GameManager.current_checkpoint != Vector2.ZERO:
		var player = get_tree().get_first_node_in_group("player") as PlayerController
		player.global_position = GameManager.current_checkpoint
	_hide_buttons()

func _hide_buttons():
	RestartButton.visible = false
	CheckpointButton.visible = false

func show_jetpack_icon():
	$JetpackIcon.visible = true
