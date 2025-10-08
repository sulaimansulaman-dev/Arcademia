extends Node2D

# -----------------------
# Nodes
# -----------------------
@onready var userName: LineEdit = $Username
@onready var password: LineEdit = $password
@onready var save_btn: Button = $SaveButton2

# -----------------------
# Constants
# -----------------------
const DB_FILE_PATH: String = "user://students.json"

# -----------------------
# Variables
# -----------------------
var _eye_btn: Button
var _pw_visible: bool = false

# -----------------------
# Ready
# -----------------------
func _ready() -> void:
	# --- Password setup ---
	password.secret = true
	password.secret_character = "*"
	password.max_length = 5
	password.placeholder_text = "5-digit PIN"
	password.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER

	password.add_theme_color_override("placeholder_color", Color(1,1,1,0.92))
	password.add_theme_color_override("font_color", Color(0,0,0,1))
	password.add_theme_color_override("caret_color", Color(0,0,0,1))
	password.add_theme_color_override("selection_color", Color(0.65,0.8,1.0,0.35))

	_eye_btn = _add_eye_toggle(password)
	
	

	# --- Connect Save button ---
	if save_btn:
		save_btn.pressed.connect(_on_save_button_pressed)
	else:
		print("⚠️ Save button not found in scene!")

# -----------------------
# Password Eye Toggle
# -----------------------
func _add_eye_toggle(field: LineEdit) -> Button:
	var btn := Button.new()
	btn.text = "👁"
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.tooltip_text = "Show/Hide PIN"

	field.add_child(btn)
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.anchor_top = 0.0
	btn.anchor_bottom = 1.0
	btn.offset_left = -34
	btn.offset_right = -4
	btn.offset_top = 2
	btn.offset_bottom = -2
	btn.custom_minimum_size = Vector2(28,0)

	btn.pressed.connect(func():
		_pw_visible = not _pw_visible
		field.secret = not _pw_visible
		btn.text = "🙈" if _pw_visible else "👁"
	)
	return btn

# -----------------------
# Save Teacher Account
# -----------------------
func _on_save_button_pressed() -> void:
	var username = userName.text.strip_edges()
	var pwd = password.text.strip_edges()

	# --- Validation ---
	if username.is_empty():
		_show_field_error(userName, "Username required")
		return
	if pwd.is_empty():
		_show_field_error(password, "Required: 5-digit PIN")
		return
	if not _is_five_digit_pin(pwd):
		_show_field_error(password, "PIN must be exactly 5 digits (0–9)")
		return

	var students: Array[Dictionary] = load_students()

	# Prevent duplicate usernames
	for s in students:
		if s.get("username", "") == username:
			_show_field_error(userName, "Username already exists")
			return

	# --- Create Teacher entry ---
	var new_teacher: Dictionary = {
		"username": username,
		"password": pwd,
		"role": "Teacher"
	}
	students.append(new_teacher)
	save_students(students)
	print("✅ Teacher account created successfully for:", username)

	# --- Switch scene ---
	get_tree().change_scene_to_file("res://avatar creation/scenes/LoginTeacher.tscn")

# -----------------------
# Inline error helpers
# -----------------------
func _show_field_error(le: LineEdit, msg: String) -> void:
	le.text = ""
	le.placeholder_text = msg
	le.add_theme_color_override("placeholder_color", Color(1,0.3,0.3,0.95))
	le.add_theme_color_override("caret_color", Color(1,0.25,0.25,1.0))

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0,0,0,0)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color(1,0.2,0.2,1.0)
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_right = 8
	sb.corner_radius_bottom_left = 8
	le.add_theme_stylebox_override("normal", sb)
	le.add_theme_stylebox_override("focus", sb)

	if le.has_focus():
		le.release_focus()
	le.queue_redraw()

func _clear_field_error(le: LineEdit) -> void:
	le.placeholder_text = "5-digit PIN" if le == password else ""
	le.remove_theme_color_override("placeholder_color")
	le.remove_theme_color_override("caret_color")
	le.remove_theme_stylebox_override("normal")
	le.remove_theme_stylebox_override("focus")

# -----------------------
# PIN validation
# -----------------------
func _is_five_digit_pin(p: String) -> bool:
	if p.length() != 5:
		return false
	for ch in p:
		if ch < "0" or ch > "9":
			return false
	return true

# -----------------------
# Data helpers
# -----------------------
func load_students() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if FileAccess.file_exists(DB_FILE_PATH):
		var f = FileAccess.open(DB_FILE_PATH, FileAccess.READ)
		var content = f.get_as_text()
		f.close()

		if content.is_empty():
			return result

		var parsed = JSON.parse_string(content)
		if parsed is Array:
			for item in parsed:
				if item is Dictionary:
					if not item.has("role"):
						item["role"] = "Student"
					result.append(item)
				else:
					print("⚠️ Skipping invalid entry in students.json")
	return result

func save_students(students: Array[Dictionary]) -> void:
	var f = FileAccess.open(DB_FILE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(students, "\t"))  # Pretty JSON
	f.close()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/LoginTeacher.tscn")
