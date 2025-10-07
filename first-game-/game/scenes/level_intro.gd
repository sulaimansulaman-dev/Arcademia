extends Control

@onready var image_display: TextureRect = $TextureRect


var images: Array[Texture2D] = []
var current_index := 0


func _ready():
	#AudioManager.play_music(AudioManager.bgm_mainmusic)
	image_display.expand = true
	image_display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image_display.size = get_viewport_rect().size
	# Pick image set based on which level is about to start
	match Globals.level_to_load:
		1:
			images = [
				load("res://story/assets/level1_1.jpg"),
				load("res://story/assets/level1_2.jpg"),
				load("res://story/assets/level1_3.jpg"),
				load("res://story/assets/level1_4.jpg"),
				load("res://story/assets/level1_5.PNG"),
				load("res://story/assets/level1_instruction.PNG")
			]
		2:
			images = [
				load("res://story/assets/level2_1.png"),
				load("res://story/assets/level2_2.png"),
				load("res://story/assets/level2_instruction.PNG")
			]
		3:
			images = [
				load("res://story/assets/level3_1.PNG"),
				load("res://story/assets/level3_2.PNG"),
				load("res://story/assets/level3_instruction.PNG")
			]
		4:
			images = [
				load("res://story/assets/level4_1.PNG")
			]
		_:
			images = []

	if images.size() > 0:
		image_display.texture = images[current_index]
	else:
		# fallback, skip straight to Blocks
		get_tree().change_scene_to_file("res://game/scenes/Blocks.tscn")

	gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			current_index += 1
			if current_index < images.size():
				image_display.texture = images[current_index]
			else:
				# done with slideshow → launch Blocks scene
				get_tree().change_scene_to_file("res://game/scenes/Blocks.tscn")
	)
	AudioManager.stop_music(1.0)
