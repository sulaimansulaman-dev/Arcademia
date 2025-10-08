extends Node2D

@onready var userName: LineEdit = $NameEdit
@onready var password: LineEdit = $PasswordEdit

const DB_FILE_PATH: String = "user://students.json" # database file

var _eye_btn: Button
var _pw_visible := false

func _ready() -> void:
	# Mask the password input + guide for 5-digit PIN
	password.secret = true
	password.secret_character = "*"
	password.max_length = 5
	password.placeholder_text = "5-digit PIN"
	password.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	# Make the placeholder nice and clear (tweak for your theme)
	password.add_theme_color_override("placeholder_color", Color(1, 1, 1, 0.92))
	# Darker typed text (adjust if your background is dark)
	password.add_theme_color_override("font_color", Color(0, 0, 0, 1.0))
	password.add_theme_color_override("caret_color", Color(0, 0, 0, 1.0))

	_add_password_eye_toggle()

	# Reset inline error styling when user types again
	password.text_changed.connect(func(_t: String) -> void: _clear_field_error(password))
	userName.text_changed.connect(func(_t: String) -> void: _clear_field_error(userName))

func _add_password_eye_toggle() -> void:
	_eye_btn = Button.new()
	_eye_btn.text = "👁"           # swap for TextureButton + icon if you prefer
	_eye_btn.flat = true
	_eye_btn.focus_mode = Control.FOCUS_NONE
	_eye_btn.tooltip_text = "Show/Hide PIN"

	password.add_child(_eye_btn)
	_eye_btn.anchor_left = 1.0
	_eye_btn.anchor_right = 1.0
	_eye_btn.anchor_top = 0.0
	_eye_btn.anchor_bottom = 1.0
	_eye_btn.offset_left = -34
	_eye_btn.offset_right = -4
	_eye_btn.offset_top = 2
	_eye_btn.offset_bottom = -2
	_eye_btn.custom_minimum_size = Vector2(28, 0)

	_eye_btn.pressed.connect(_on_eye_pressed)

func _on_eye_pressed() -> void:
	_pw_visible = not _pw_visible
	password.secret = not _pw_visible
	_eye_btn.text = "🙈" if _pw_visible else "👁"

func _on_save_button_pressed() -> void:
	var username: String = userName.text.strip_edges()
	var pwd: String = password.text.strip_edges()

	# --- Validation ---
	var has_empty := false
	if username.is_empty():
		_show_field_error(userName, "Username required")
		has_empty = true
	if pwd.is_empty():
		_show_field_error(password, "Required: 5-digit PIN")
		has_empty = true
	if has_empty:
		return

	# Enforce exactly 5 digits (numbers only)
	if not _is_five_digit_pin(pwd):
		_show_field_error(password, "PIN must be exactly 5 digits (0–9)")
		return

	# --- Create new student entry ---
	var new_student: Dictionary = {
		"username": username,
		"password": pwd
	}

	var students: Array[Dictionary] = load_students()

	# Prevent duplicate usernames
	for student: Dictionary in students:
		if student.get("username", "") == username:
			_show_field_error(userName, "Username already exists")
			return

	students.append(new_student)
	save_students(students)

	print("✅ Saved new student:", new_student)

	# Switch to main menu
	get_tree().change_scene_to_file("res://main menu/scenes/MainMenu.tscn")


# --- Inline error helpers (no Label nodes needed) ---
func _show_field_error(le: LineEdit, msg: String) -> void:
	if le == null:
		return

	le.text = ""
	le.placeholder_text = msg

	le.add_theme_color_override("placeholder_color", Color(1.0, 0.3, 0.3, 0.95))
	le.add_theme_color_override("caret_color", Color(1.0, 0.25, 0.25, 1.0))

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color(1.0, 0.2, 0.2, 1.0)
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_right = 8
	sb.corner_radius_bottom_left = 8
	le.add_theme_stylebox_override("normal", sb)
	le.add_theme_stylebox_override("focus", sb)

	if le.has_focus():
		le.release_focus()
	le.queue_redraw()

	_shake_line_edit(le)

func _clear_field_error(le: LineEdit) -> void:
	if le == null:
		return
	if le == password:
		le.placeholder_text = "5-digit PIN"
	elif le == userName:
		le.placeholder_text = ""  # or your own hint

	le.remove_theme_color_override("placeholder_color")
	le.remove_theme_color_override("caret_color")
	le.remove_theme_stylebox_override("normal")
	le.remove_theme_stylebox_override("focus")

func _shake_line_edit(le: LineEdit) -> void:
	if le == null:
		return
	var start := le.position
	var t := create_tween()
	t.tween_property(le, "position:x", start.x - 6, 0.05)
	t.tween_property(le, "position:x", start.x + 6, 0.05)
	t.tween_property(le, "position:x", start.x, 0.05)


# --- Helpers ---
func _is_five_digit_pin(p: String) -> bool:
	if p.length() != 5:
		return false
	for ch in p:
		if ch < "0" or ch > "9":
			return false
	return true

func load_students() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if FileAccess.file_exists(DB_FILE_PATH):
		var file: FileAccess = FileAccess.open(DB_FILE_PATH, FileAccess.READ)
		var content: String = file.get_as_text()
		file.close()

		var parsed: Variant = JSON.parse_string(content)
		if parsed is Array:
			for item in (parsed as Array):
				if item is Dictionary:
					result.append(item as Dictionary)
				else:
					print("Warning: Skipping non-dictionary entry in students.json")
	return result

func save_students(students: Array[Dictionary]) -> void:
	var file: FileAccess = FileAccess.open(DB_FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(students, "\t")) # formatted JSON
	file.close()
