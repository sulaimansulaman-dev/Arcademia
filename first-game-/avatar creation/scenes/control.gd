extends Node2D

# Texture arrays
var skin_textures: Array = []
var mouth_textures: Array = []
var eyes_textures: Array = []
var hair_textures: Array = []
var accessories_textures: Array = []
var outfit_textures: Array = []
var fullsuit_textures: Array = []

# Current indices
var current_skin := 0
var current_mouth := 0
var current_eyes := 0
var current_hair := 0
var current_accessories := 0
var current_outfit := 0
var current_fullsuit := 0

# Backup previous choices
var previous_hair := 0
var previous_accessories := 0
var previous_outfit := 0

# Nodes
@onready var avatar := $CenterContainer/Skeleton
@onready var save_button := $SaveButton

@onready var val_labels := {
	"Skin":        $Panel/CenterContainer/ValSkin,
	"Mouth":       $Panel2/CenterContainer/ValMouth,
	"Eyes":        $Panel3/CenterContainer/ValEyes,
	"Hair":        $Panel4/CenterContainer/ValHair,
	"Accessories": $Panel6/CenterContainer/ValAccessories,
	"Outfit":      $Panel5/CenterContainer/ValOutfit,
	"FullSuit":    $Panel7/CenterContainer/ValFullSuit
}

@onready var prev_buttons := {
	"Skin":        $PrevSkin,
	"Mouth":       $PrevMouth,
	"Eyes":        $PrevEyes,
	"Hair":        $PrevHair,
	"Accessories": $PrevAccessories,
	"Outfit":      $PrevOutfit,
	"FullSuit":    $PrevFullSuit
}

@onready var next_buttons := {
	"Skin":        $NextSkin,
	"Mouth":       $NextMouth,
	"Eyes":        $NextEyes,
	"Hair":        $NextHair,
	"Accessories": $NextAccessories,
	"Outfit":      $NextOutfit,
	"FullSuit":    $NextFullSuit
}

func _ready() -> void:
	# Load textures (required folders must have at least 1 image)
	skin_textures = load_textures("res://avatar creation/assets/avatars/skin/")
	mouth_textures = load_textures("res://avatar creation/assets/avatars/mouth/")
	eyes_textures = load_textures("res://avatar creation/assets/avatars/eyes/")

	# Optional folders allow empty, with a "None" option
	hair_textures = [null] + load_textures("res://avatar creation/assets/avatars/hair/", true)
	accessories_textures = [null] + load_textures("res://avatar creation/assets/avatars/accessories/", true)
	outfit_textures = load_textures("res://avatar creation/assets/avatars/outfits/", true)
	fullsuit_textures = [null] + load_textures("res://avatar creation/assets/avatars/fullsuit/", true)

	# Connect buttons
	for cat in prev_buttons.keys():
		prev_buttons[cat].pressed.connect(Callable(self, "cycle_texture").bind(cat, -1))
		next_buttons[cat].pressed.connect(Callable(self, "cycle_texture").bind(cat, 1))

	save_button.pressed.connect(_on_save_button_pressed)

	_update_all_labels()
	_update_avatar()


func load_textures(path: String, allow_empty: bool = false) -> Array:
	var textures: Array = []
	var dir := DirAccess.open(path)
	if dir:
		for file in dir.get_files():
			if file.to_lower().ends_with(".png"):
				textures.append(load(path + file))
	else:
		push_error("Could not open directory: " + path)

	# Handle empty folder
	if textures.is_empty():
		if allow_empty:
			return []  # Add [null] externally if needed
		else:
			push_error("Required texture folder is empty: " + path)
			get_tree().quit()
	return textures


func _name(tex: Texture2D) -> String:
	if tex == null:
		return "None"
	var base := tex.resource_path.get_file().get_basename()
	base = base.replace("_", " ")
	var out := ""
	for w in base.split(" "):
		out += w.capitalize() + " "
	return out.strip_edges()


func _update_all_labels() -> void:
	val_labels["Skin"].text = _name(skin_textures[current_skin])
	val_labels["Mouth"].text = _name(mouth_textures[current_mouth])
	val_labels["Eyes"].text = _name(eyes_textures[current_eyes])
	val_labels["Hair"].text = _name(hair_textures[current_hair])
	val_labels["Accessories"].text = _name(accessories_textures[current_accessories])
	if outfit_textures.size() > 0:
		val_labels["Outfit"].text = _name(outfit_textures[current_outfit])
	else:
		val_labels["Outfit"].text = "None"
	val_labels["FullSuit"].text = _name(fullsuit_textures[current_fullsuit])


func _update_avatar() -> void:
	avatar.get_node("Skin").texture = skin_textures[current_skin]
	avatar.get_node("Mouth").texture = mouth_textures[current_mouth]
	avatar.get_node("Eyes").texture = eyes_textures[current_eyes]

	var fullsuit_texture = fullsuit_textures[current_fullsuit]

	if fullsuit_texture != null:
		# Save current hair, accessories, and outfit before hiding
		previous_hair = current_hair
		previous_accessories = current_accessories
		previous_outfit = current_outfit

		avatar.get_node("Hair").texture = null
		avatar.get_node("Accessories").texture = null
		avatar.get_node("Outfit").texture = null
		avatar.get_node("FullSuit").texture = fullsuit_texture
		
		# Disable UI controls for Hair, Accessories, Outfit
		_set_disabled_state_for_fullsuit(true)
		
	else:
		# Restore hair, accessories, and outfit from previous selection
		avatar.get_node("Hair").texture = hair_textures[current_hair]
		avatar.get_node("Accessories").texture = accessories_textures[current_accessories]

		if outfit_textures.size() > 0:
			avatar.get_node("Outfit").texture = outfit_textures[current_outfit]
		else:
			avatar.get_node("Outfit").texture = null

		avatar.get_node("FullSuit").texture = null
		# Re-enable UI controls
		_set_disabled_state_for_fullsuit(false)

	_update_all_labels()
	_center_avatar_and_scale()

func cycle_texture(category: String, direction: int) -> void:
	AudioManager.play_sound(AudioManager.sfx_nav)
	match category:
		"Skin":
			current_skin = (current_skin + direction + skin_textures.size()) % skin_textures.size()
		"Mouth":
			current_mouth = (current_mouth + direction + mouth_textures.size()) % mouth_textures.size()
		"Eyes":
			current_eyes = (current_eyes + direction + eyes_textures.size()) % eyes_textures.size()
		"Hair":
			current_hair = (current_hair + direction + hair_textures.size()) % hair_textures.size()
		"Accessories":
			current_accessories = (current_accessories + direction + accessories_textures.size()) % accessories_textures.size()
		"Outfit":
			if outfit_textures.size() > 0:
				current_outfit = (current_outfit + direction + outfit_textures.size()) % outfit_textures.size()
		"FullSuit":
			current_fullsuit = (current_fullsuit + direction + fullsuit_textures.size()) % fullsuit_textures.size()

	_update_avatar()


func _on_save_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_save)
	print("Save pressed:")
	print("Skin:", current_skin)
	print("Mouth:", current_mouth)
	print("Eyes:", current_eyes)
	print("Hair:", current_hair)
	print("Accessories:", current_accessories)
	print("Outfit:", current_outfit)
	print("FullSuit:", current_fullsuit)
	get_tree().change_scene_to_file("res://avatar creation/scenes/StudentEntry.tscn")


func _center_avatar_and_scale() -> void:
	var display_size = Vector2(598, 650)  # Target display box size

	var skin_node = avatar.get_node_or_null("Skin")
	if skin_node and skin_node.texture:
		var tex_size = skin_node.texture.get_size()

		if tex_size.x > 0 and tex_size.y > 0:
			var scale_factor = min(display_size.x / tex_size.x, display_size.y / tex_size.y)
			
			# Increase scale by 20% (1.2)
			var new_scale = scale_factor * 1.2
			avatar.scale = Vector2(new_scale, new_scale)

			# Center avatar - adjust if needed
			avatar.position = display_size * 0.5

func _set_disabled_state_for_fullsuit(active: bool) -> void:
	var tooltip_text := "Cannot be used with Full Suit" if active else ""

	# Hair buttons
	prev_buttons["Hair"].disabled = active
	next_buttons["Hair"].disabled = active
	prev_buttons["Hair"].tooltip_text = tooltip_text
	next_buttons["Hair"].tooltip_text = tooltip_text

	# Accessories buttons
	prev_buttons["Accessories"].disabled = active
	next_buttons["Accessories"].disabled = active
	prev_buttons["Accessories"].tooltip_text = tooltip_text
	next_buttons["Accessories"].tooltip_text = tooltip_text

	# Outfit buttons
	prev_buttons["Outfit"].disabled = active
	next_buttons["Outfit"].disabled = active
	prev_buttons["Outfit"].tooltip_text = tooltip_text
	next_buttons["Outfit"].tooltip_text = tooltip_text

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("back_action"):
		_on_back_button_pressed()

func _on_back_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_menuclose)
	get_tree().change_scene_to_file("res://avatar creation/scenes/LoginStudent.tscn")


func _on_save_button_pressed() -> void:
	print("Save pressed:")
	print("Skin:", current_skin)
	print("Mouth:", current_mouth)
	print("Eyes:", current_eyes)
	print("Hair:", current_hair)
	print("Accessories:", current_accessories)
	print("Outfit:", current_outfit)
	print("FullSuit:", current_fullsuit)
	get_tree().change_scene_to_file("res://avatar creation/scenes/StudentEntry.tscn")
