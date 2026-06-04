extends Node

signal area_started

@export var current_area: int = 1
var area_path = "res://Scenes/Areas/"

var energy_cells = 0
var area_container : Node2D
var player : PlayerController
var hud : HUD
var checkpoints: Array[Vector2] = []
var current_checkpoint: Vector2 = Vector2.ZERO
var has_jetpack: bool = false



func _ready():
	hud = get_tree().get_first_node_in_group("hud")
	area_container = get_tree().get_first_node_in_group("area_container")
	player = get_tree().get_first_node_in_group("player")
	load_area(current_area)

func next_area():
	current_area += 1
	load_area(current_area)

func load_area(area_number): 
	#Checking the new scene path
	current_area = area_number   # keep current_area in sync
	var full_path = area_path + "area_" + str(area_number) + ".tscn"
	var scene = load(full_path) as PackedScene
	if !scene:
		return
	#removing previous scene
	for child in area_container.get_children(): 
		child.queue_free()
		await child.tree_exited
	# Setting up the new scene
	var instance = scene.instantiate()
	area_container.add_child(instance)
	reset_energy_cells()
	#moving player to the star position of the new scene
	var player_start_position = get_tree().get_first_node_in_group("player_start_position") as Node2D
	player.teleport_to_location(player_start_position.position)
	area_started.emit()
	# jetpack activate area from 4
	if area_number >= 4:
		has_jetpack = true
		hud.show_jetpack_icon()


#energy cell pickup
func add_energy_cells(cell_position: Vector2):
	energy_cells += 1
	hud.update_energy_cell_label(energy_cells)
	var audio_manager = get_tree().get_first_node_in_group("audio_manager") as AudioManager
	audio_manager.play_energy_cell_pickup()
	# Save checkpoint
	checkpoints.append(cell_position)
	current_checkpoint = cell_position

	if energy_cells >= 3:
		var portal = get_tree().get_first_node_in_group("area_exits") as AreaExit
		portal.open()
		audio_manager.play_portal_open()
		hud.portal_opened()

func reset_energy_cells():
	energy_cells = 0
	hud.update_energy_cell_label(energy_cells)
	hud.portal_closed()

# jetpack pickup
func pickup_jetpack(cell_position: Vector2):
	has_jetpack = true
	if hud:
		hud.show_jetpack_popup("Jetpack  activated  —  you  can  double  jump", 6.0)
	hud.show_jetpack_icon()
