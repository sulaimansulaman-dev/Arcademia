extends Control

@onready var image_display: TextureRect = $TextureRect
var images: Array[Texture2D] = []
var current_index := 0

func _ready():
	image_display.expand = true
	image_display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image_display.size = get_viewport_rect().size

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
		get_tree().change_scene_to_file("res://main menu/scenes/MainMenu.tscn")

	gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			current_index += 1
			if current_index < images.size():
				image_display.texture = images[current_index]
			else:
				# when slideshow is done, head back to main menu
				get_tree().change_scene_to_file("res://main menu/scenes/MainMenu.tscn")
	)
