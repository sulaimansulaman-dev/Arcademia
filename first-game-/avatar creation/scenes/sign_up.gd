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


# ==========================
#   Inline error helpers
# ==========================
func _show_field_error(le: LineEdit, msg: String) -> void:
	# Clear input and show red placeholder + red border
	le.text = ""
	le.placeholder_text = msg

	# Red placeholder & caret
	le.add_theme_color_override("placeholder_color", Color(1.0, 0.3, 0.3, 0.95))
	le.add_theme_color_override("caret_color", Color(1.0, 0.25, 0.25, 1.0))

	# Red border via StyleBoxFlat (Godot 4: per-side/per-corner)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0) # keep background transparent; just draw border
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

	# Ensure placeholder shows even if focused
	if le.has_focus():
		le.release_focus()
	le.queue_redraw()

	# Light shake to draw attention (optional)
	_shake_line_edit(le)

func _clear_field_error(le: LineEdit) -> void:
	# Restore standard placeholders
	if le == password:
		le.placeholder_text = "5-digit PIN"
	elif le == passwordConfirm:
		le.placeholder_text = "Repeat 5-digit PIN"
	elif le == userName:
		le.placeholder_text = ""  # or set your own hint

	# Restore colours back to theme/previous overrides
	le.remove_theme_color_override("placeholder_color")
	le.remove_theme_color_override("caret_color")

	# Remove red border overrides
	le.remove_theme_stylebox_override("normal")
	le.remove_theme_stylebox_override("focus")

func _shake_line_edit(le: LineEdit) -> void:
	# Simple horizontal shake (may be subtle inside Containers)
	var start := le.position
	var t := create_tween()
	t.tween_property(le, "position:x", start.x - 6, 0.05)
	t.tween_property(le, "position:x", start.x + 6, 0.05)
	t.tween_property(le, "position:x", start.x,       0.05)


# ==========================
#        Data helpers
# ==========================
func _is_five_digit_pin(p: String) -> bool:
	# Exactly 5 chars AND all digits 0–9 (leading zeros allowed)
	if p.length() != 5:
		return false
	for ch in p:
		if ch < "0" or ch > "9":
			return false
	return true

func load_students() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if FileAccess.file_exists(DB_FILE_PATH):
		var f: FileAccess = FileAccess.open(DB_FILE_PATH, FileAccess.READ)
		var content: String = f.get_as_text()
		f.close()

		var parsed: Variant = JSON.parse_string(content)
		if parsed is Array:
			# Safely coerce each element to Dictionary
			for item in (parsed as Array):
				if item is Dictionary:
					result.append(item as Dictionary)
				else:
					print("Warning: Skipping non-dictionary entry in students.json")
	return result

func save_students(students: Array[Dictionary]) -> void:
	var f: FileAccess = FileAccess.open(DB_FILE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(students, "\t")) # formatted JSON
	f.close()
