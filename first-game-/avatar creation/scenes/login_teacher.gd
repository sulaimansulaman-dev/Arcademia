extends Node2D

@onready var userName: LineEdit = $NameEdit
@onready var password: LineEdit = $Password

const DB_FILE_PATH: String = "user://students.json"

var _eye_btn: Button
var _pw_visible := false

func _ready() -> void:
	# Mask the password input
	password.secret = true
	password.secret_character = "*"

	# Add an eye toggle button inside the password field
	_add_password_eye_toggle()

func _add_password_eye_toggle() -> void:
	_eye_btn = Button.new()
	_eye_btn.text = "👁"                    # swap to TextureButton + icon if you prefer
	_eye_btn.flat = true
	_eye_btn.focus_mode = Control.FOCUS_NONE
	_eye_btn.tooltip_text = "Show/Hide password"

	# Nest the button inside the LineEdit and anchor to the right edge
	password.add_child(_eye_btn)
	_eye_btn.anchor_left = 1.0
	_eye_btn.anchor_right = 1.0
	_eye_btn.anchor_top = 0.0
	_eye_btn.anchor_bottom = 1.0
	# Tweak these to fit your theme
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
	# Go to Sign Up scene (generic signup)
	get_tree().change_scene_to_file("res://avatar creation/scenes/SignUp_teacher.tscn")

func _on_save_button_2_pressed() -> void:
	var username: String = userName.text.strip_edges()
	var pwd: String = password.text.strip_edges()

	# --- Validation ---
	if username.is_empty() or pwd.is_empty():
		print("⚠️ Username and Password cannot be empty")
		var msg = AcceptDialog.new()
		msg.dialog_text = "⚠️ Username and Password cannot be empty"
		get_tree().root.add_child(msg)
		msg.popup_centered()

		return

	var students: Array[Dictionary] = load_students()

	# --- Check credentials ---
	for student: Dictionary in students:
		var s_user: String = str(student.get("username", ""))
		var s_pass: String = str(student.get("password", ""))

		# If credentials match, we then verify teacher marker
		if s_user == username and s_pass == pwd:
			# 1) Check explicit role field (if present)
			var role_field: String = str(student.get("role", "")).to_lower()

			# 2) Check if both username & password *end* with "teacher" (case-insensitive)
			var s_user_lower := s_user.to_lower()
			var s_pass_lower := s_pass.to_lower()
			var ends_with_teacher := s_user_lower.ends_with("teacher") and s_pass_lower.ends_with("teacher")

			if role_field == "teacher" or ends_with_teacher:
				print("✅ Teacher login successful for:", username)
				# Change to your teacher scene
				get_tree().change_scene_to_file("res://student management/Scene/display.tscn")
				return
			else:
				print("❌ Access denied — this account is not marked as a teacher")
				password.text = ""
				return

	# No match
	print("❌ Wrong username or password. Try again")
	var msg = AcceptDialog.new()
	msg.dialog_text = "❌ Wrong username or password. Try again"
	get_tree().root.add_child(msg)
	msg.popup_centered()

	password.text = ""  # clear password field


# -----------------------
#        Helpers
# -----------------------
func load_students() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if FileAccess.file_exists(DB_FILE_PATH):
		var f: FileAccess = FileAccess.open(DB_FILE_PATH, FileAccess.READ)
		var content: String = f.get_as_text()
		f.close()

		var parsed: Variant = JSON.parse_string(content)
		# JSON.parse_string returns an Array/Dictionary/Variant, handle safely
		if parsed is Array:
			for item in (parsed as Array):
				if item is Dictionary:
					result.append(item as Dictionary)
				else:
					print("Warning: Skipping non-dictionary entry in students.json")
	return result

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("back_action"):
		_on_back_button_pressed()
		
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/SelectUser.tscn")
