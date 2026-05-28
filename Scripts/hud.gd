extends Control
class_name HUD

@export var energy_cell_label: Label
@export var portal_label : Label
@export var stopwatch_label : Label

var stopwatch : stopwatch

func _ready():
	stopwatch = get_tree().get_first_node_in_group("stopwatch")

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
