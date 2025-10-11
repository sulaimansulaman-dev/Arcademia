extends Node2D

@onready var userName: LineEdit        = $Username
@onready var password: LineEdit        = $password
@onready var passwordConfirm: LineEdit = $passwordCon

const DB_FILE_PATH: String = "user://students.json" # auto-created if missing

# Track visibility state per field
var _pw_visible: bool = false
var _pw_confirm_visible: bool = false

# Keep references to the eye buttons if you want to tweak them later
var _eye_btn_pw: Button
var _eye_btn_confirm: Button

func _ready() -> void:
	# Mask password inputs + guide the user for a 5-digit PIN
	password.secret = true
	password.secret_character = "*"
	password.max_length = 5
	password.placeholder_text = "5-digit PIN"
	password.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER

	passwordConfirm.secret = true
	passwordConfirm.secret_character = "*"
	passwordConfirm.max_length = 5
	passwordConfirm.placeholder_text = "Repeat 5-digit PIN"
	passwordConfirm.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER

	# Make placeholder text clearer (good for dark UIs)
	password.add_theme_color_override("placeholder_color", Color(1, 1, 1, 0.92))
	passwordConfirm.add_theme_color_override("placeholder_color", Color(1, 1, 1, 0.92))

	# Make typed text very dark (black), and match the caret
	password.add_theme_color_override("font_color", Color(0, 0, 0, 1.0))
	passwordConfirm.add_theme_color_override("font_color", Color(0, 0, 0, 1.0))
	password.add_theme_color_override("caret_color", Color(0, 0, 0, 1.0))
	passwordConfirm.add_theme_color_override("caret_color", Color(0, 0, 0, 1.0))

	# Optional: selection colour for readability on light backgrounds
	password.add_theme_color_override("selection_color", Color(0.65, 0.80, 1.0, 0.35))
	passwordConfirm.add_theme_color_override("selection_color", Color(0.65, 0.80, 1.0, 0.35))

	# Reset error styling when user starts typing
	userName.text_changed.connect(func(_t: String) -> void: _clear_field_error(userName))
	password.text_changed.connect(func(_t: String) -> void: _clear_field_error(password))
	passwordConfirm.text_changed.connect(func(_t: String) -> void: _clear_field_error(passwordConfirm))

	# Add the eye toggle buttons inside each LineEdit
	_eye_btn_pw = _add_eye_toggle(password, false)
	_eye_btn_confirm = _add_eye_toggle(passwordConfirm, true)

func _add_eye_toggle(field: LineEdit, is_confirm: bool) -> Button:
	var btn := Button.new()
	btn.text = "👁" # swap to TextureButton + icon if you prefer PNGs
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.tooltip_text = "Show/Hide PIN"

	# Nest the button inside the LineEdit and anchor to the right
	field.add_child(btn)
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.anchor_top = 0.0
	btn.anchor_bottom = 1.0
	# Tweak these to fit your theme
	btn.offset_left = -34
	btn.offset_right = -4
	btn.offset_top = 2
	btn.offset_bottom = -2
	btn.custom_minimum_size = Vector2(28, 0)

	# Bind a pressed callback for this specific field
	btn.pressed.connect(func():
		if is_confirm:
			_pw_confirm_visible = not _pw_confirm_visible
			field.secret = not _pw_confirm_visible
			btn.text = "🙈" if _pw_confirm_visible else "👁"
		else:
			_pw_visible = not _pw_visible
			field.secret = not _pw_visible
			btn.text = "🙈" if _pw_visible else "👁"
	)
	return btn

func _on_save_button_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_menuopen)
	
	var username: String    = userName.text.strip_edges()
	var pwd: String         = password.text.strip_edges()
	var confirm_pwd: String = passwordConfirm.text.strip_edges()

	# --- Validation: empties ---
	var has_empty := false
	if username.is_empty():
		_show_field_error(userName, "Username required")
		has_empty = true
	if pwd.is_empty():
		_show_field_error(password, "Required: 5-digit PIN")
		has_empty = true
	if confirm_pwd.is_empty():
		_show_field_error(passwordConfirm, "Repeat 5-digit PIN")
		has_empty = true
	if has_empty:
		return

	# --- Validation: numeric 5-digit PIN for both fields ---
	if not _is_five_digit_pin(pwd):
		_show_field_error(password, "PIN must be exactly 5 digits (0–9)")
		return
	if not _is_five_digit_pin(confirm_pwd):
		_show_field_error(passwordConfirm, "PIN must be exactly 5 digits (0–9)")
		return

	# --- Validation: match ---
	if pwd != confirm_pwd:
		_show_field_error(passwordConfirm, "PINs do not match")
		return

	var students: Array[Dictionary] = load_students()

	# Prevent duplicate usernames
	for s: Dictionary in students:
		if s.get("username", "") == username:
			_show_field_error(userName, "Username already exists")
			return

	# --- Create and save entry ---
	var new_student: Dictionary = {
		"username": username,
		"password": pwd
	}
	students.append(new_student)
	save_students(students)

	print("✅ Saved new student:", new_student)

	# Switch scene
	get_tree().change_scene_to_file("res://student management/Scene/display.tscn")


func load_students() -> Array:
	if FileAccess.file_exists(db_file_path):
		var file = FileAccess.open(db_file_path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(content)
		if parsed != null:
			return parsed
	return []


func save_students(students: Array) -> void:
	var file = FileAccess.open(db_file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(students, "\t"))  # formatted JSON
	file.close()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/LoginTeacher.tscn")
