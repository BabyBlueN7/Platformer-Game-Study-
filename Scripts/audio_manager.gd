extends Node

class_name AudioManager

# energy cell pick sound
func play_energy_cell_pickup():
	$EnergyCellPickupSound.play()

# portal open sound
func play_portal_open():
	$PortalOpenSound.play()

# jump sound
func play_jump():
	$JumpSound.play()

# Walking sound
func start_walking():
	if not $WalkingSound.playing:
		$WalkingSound.play()

func stop_walking():
	if $WalkingSound.playing:
		$WalkingSound.stop()

# land
func play_land():
	$LandSound.play()

# jetpack  sound
func play_jetpack():
	$JetpackSound.play()

# resurrection sound
func play_resurrection():
	if $ResurrectionSound:
		$ResurrectionSound.play()

# --- new music controls ---
func stop_all_music():
	$Area1Music.stop()
	$Area2Music.stop()
	$Area3Music.stop()
	$Area4Music.stop()

func play_area_music(area_number: int):
	stop_all_music()
	match area_number:
		1:
			$Area1Music.play()
		2:
			$Area2Music.play()
		3:
			$Area3Music.play()
		4:
			$Area4Music.play()
