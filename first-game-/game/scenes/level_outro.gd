extends Control

@onready var image_display: TextureRect = $TextureRect
@onready var score_label = $TextureRect/Label
var images: Array[Texture2D] = []
var current_index := 0 

func _ready():
	AudioManager.play_music(AudioManager.bgm_mainmusic)
	image_display.expand = true
	image_display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image_display.size = get_viewport_rect().size
	# Set the Score to the Score Value
	score_label.text = "Your Score is : \n " + str(Globals.final_score) + " Blocks"

	# Pick image set based on which level just finished
	match Globals.level_to_load:
		1:
			images = [
				load("res://story/assets/level1_steering_wheel.jpg"),
			]
			
		2:
			images = [
				load("res://story/assets/level2_fuel_tank.png"),
			]
		3:
			images = [
				load("res://story/assets/level1_steering_wheel.jpg")
			]
		4:
			images = [
				load("res://story/assets/level4_2.PNG")
			]
		_:
			images = []

	if images.size() > 0:
		image_display.texture = images[current_index]
	else:
		# fallback if nothing is set
		get_tree().change_scene_to_file("res://avatar creation/Natashas_Stuff/main menu/scenes/MainMenu.tscn")

	gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			current_index += 1
			if current_index < images.size():
				image_display.texture = images[current_index]
			else:
				# Unlock the next level before returning to menu
				if Globals.level_to_load < 4:
					Globals.unlocked_levels = max(Globals.unlocked_levels, Globals.level_to_load + 1)
				
				get_tree().change_scene_to_file("res://main menu/scenes/MainMenu.tscn")
	)
