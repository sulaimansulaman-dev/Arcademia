extends Control

# Array of image paths
var images = [
	"res://download.jpg",
	"res://level 1 steering whel.png"
	# Alternative: "res://level_1_steering_wheel.png" # Uncomment if renamed
]
var textures = [] # To store loaded textures
var current_image_index = 0 # Track current image
var is_animating = false # Prevent clicks during animation

# Reference to nodes
@onready var texture_rect = $TextureRect
@onready var animation_player = $AnimationPlayer

func _ready():
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
		texture_rect.texture = textures[current_image_index]
	else:
		print("Error: No valid textures loaded. Check image paths.")
	
	# Make TextureRect fill the viewport
	var viewport_size = get_viewport_rect().size
	texture_rect.rect_size = viewport_size
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Center the TextureRect
	texture_rect.rect_position = Vector2.ZERO
	
	# Ensure TextureRect receives mouse input
	texture_rect.mouse_filter = MOUSE_FILTER_PASS
	
	# Connect AnimationPlayer signal
	if animation_player:
		animation_player.connect("animation_finished", _on_animation_finished)
	else:
		print("Error: AnimationPlayer node not found.")

func _gui_input(event):
	# Check for left mouse click on TextureRect
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Left click detected on TextureRect!") # Debug print
		if not is_animating:
			is_animating = true
			if animation_player.has_animation("fade"):
				animation_player.play("fade")
			else:
				print("Error: 'fade' animation not found in AnimationPlayer.")
				is_animating = false

func _on_animation_finished(anim_name):
	if anim_name == "fade":
		# Switch to next image
		current_image_index = (current_image_index + 1) % textures.size()
		texture_rect.texture = textures[current_image_index]
		print("Switched to image index: ", current_image_index) # Debug print
		is_animating = false
