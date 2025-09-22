extends Node2D

# Array of image paths
var images = [
	"res://story1/1.jpg",
	"res://story1/2.jpg",
	"res://story1/3.jpg",
	"res://story1/4.jpg",
	"res://story1/5.jpg",
	"res://story1/6.jpg"
]
var textures = [] # To store loaded textures
var current_image_index = 0 # Start at index 1 (second image)
var is_animating = false # Prevent clicks during animation
var has_finished_sequence = false # Track if sequence is complete

# Reference to nodes
@onready var texture_rect = $TextureRect
@onready var animation_player = $AnimationPlayer

# Path to the next scene
var next_scene_path = "res://game/scenes/Blocks.tscn" # Replace with your scene path

func _ready():
	# Verify node references
	if not texture_rect:
		print("Error: TextureRect node not found.")
	if not animation_player:
		print("Error: AnimationPlayer node not found.")
	
	# Load all images into textures
	for path in images:
		var texture = load(path)
		if texture:
			textures.append(texture)
		else:
			print("Error: Failed to load image at path: ", path)
	print("Loaded textures: ", textures.size()) # Debug print
	
	# Set initial image
	if textures.size() > 0:
		if current_image_index < textures.size():
			texture_rect.texture = textures[current_image_index]
			print("Initial image set to index: ", current_image_index)
		else:
			print("Error: Starting index ", current_image_index, " is out of bounds.")
	else:
		print("Error: No valid textures loaded. Check image paths.")
	
	# Make TextureRect fill the viewport
	var viewport_size = get_viewport_rect().size
	texture_rect.size = viewport_size
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Center the TextureRect
	texture_rect.position = Vector2.ZERO
	
	# Ensure visibility
	texture_rect.visible = true
	texture_rect.modulate = Color(1, 1, 1, 1) # Fully opaque
	print("TextureRect visible: ", texture_rect.visible)
	print("TextureRect modulate: ", texture_rect.modulate)
	print("TextureRect position: ", texture_rect.position)
	print("TextureRect size: ", texture_rect.size)
	
	# Connect AnimationPlayer signal
	if animation_player and not animation_player.is_connected("animation_finished", _on_animation_finished):
		animation_player.connect("animation_finished", _on_animation_finished)
	else:
		print("Error: Failed to connect animation_finished signal.")

func _input(event):
	# Check for left mouse click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Left click detected!") # Debug print
		if not is_animating and not has_finished_sequence:
			is_animating = true
			if animation_player and animation_player.has_animation("fade"):
				print("Playing fade animation")
				animation_player.play("fade")
			else:
				print("Error: 'fade' animation not found or AnimationPlayer missing.")
				is_animating = false

func _on_animation_finished(anim_name):
	if anim_name == "fade":
		# Move to previous image (downwards)
		current_image_index -= 1
		if current_image_index >= 0:
			# Update to next image
			texture_rect.texture = textures[current_image_index]
			texture_rect.modulate = Color(1, 1, 1, 1) # Ensure opacity after switch
			print("Switched to image index: ", current_image_index)
			is_animating = false
		else:
			# Sequence is complete, transition to next scene
			has_finished_sequence = true
			is_animating = false
			print("Image sequence complete. Changing to scene: ", next_scene_path)
			if ResourceLoader.exists(next_scene_path):
				get_tree().change_scene_to_file(next_scene_path)
			else:
				print("Error: Next scene not found at path: ", next_scene_path)
