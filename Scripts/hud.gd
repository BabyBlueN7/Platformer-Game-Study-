extends Control
class_name HUD

@export var energy_cell_label: Label
@export var portal_label : Label

func update_energy_cell_label(number : int):
	energy_cell_label.text = "x " + str(number)

func portal_opened():
	portal_label.text = "Portal Opened!"

func portal_closed():
	portal_label.text = "Portal Closed... Need 3 Energy Cells"
