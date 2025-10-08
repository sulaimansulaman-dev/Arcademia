extends Node2D

# -----------------------
# Nodes
# -----------------------
@onready var userName: LineEdit = $Username
@onready var password: LineEdit = $password

# -----------------------
# Constants
# -----------------------
const DB_FILE_PATH: String = "user://students.json"

# -----------------------
# Variables
# -----------------------
var _eye_btn: Button
var _pw_visible := false

# -----------------------
# Ready
# -----------------------
func _ready() -> void:
	if password:
		password.secret = true
		password.secret_character = "*"
		_add_password_eye_toggle()
	else:
		print("⚠️ Password field not found in scene!")

# -----------------------
# Password Eye Toggle
# -----------------------
func _add_password_eye_toggle() -> void:
	_eye_btn = Button.new()
	_eye_btn.text = "👁"
	_eye_btn.flat = true
	_eye_btn.focus_mode = Control.FOCUS_NONE
	_eye_btn.tooltip_text = "Show/Hide password"
	
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

# -----------------------
# Scene Change (Normal Sign Up)
# -----------------------
func _on_save_button_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/SignUp.tscn")

# -----------------------
# Teacher Account Creation
# -----------------------
func _on_save_button_2_pressed() -> void:
	var username = userName.text.strip_edges()
	var pwd = password.text.strip_edges()
	
	if username.is_empty() or pwd.is_empty():
		print("⚠️ Username and Password cannot be empty")
		return

	var students = load_students()

	# Prevent duplicate username
	for student in students:
		if student.get("username", "") == username:
			print("⚠️ Account with this username already exists")
			return

	# Create Teacher account
	var new_teacher = {
		"username": username,
		"password": pwd,
		"role": "Teacher"
	}

	students.append(new_teacher)
	save_students(students)
	print("✅ Teacher account created successfully for:", username)

	# Go to Login scene
	get_tree().change_scene_to_file("res://avatar creation/scenes/Login.tscn")

# -----------------------
# Helpers: Load Students
# -----------------------
func load_students() -> Array:
	var result: Array = []

	if FileAccess.file_exists(DB_FILE_PATH):
		var f = FileAccess.open(DB_FILE_PATH, FileAccess.READ)
		var content = f.get_as_text()
		f.close()
		
		if content.empty():
			return result
		
		var parsed = JSON.parse_string(content)
		if parsed.error == OK and parsed.result is Array:
			for item in parsed.result:
				if item is Dictionary:
					result.append(item)
				else:
					print("⚠️ Skipping invalid entry in students.json")
		else:
			print("⚠️ Failed to parse students.json")
	
	return result

# -----------------------
# Helpers: Save Students
# -----------------------
func save_students(students: Array) -> void:
	var f = FileAccess.open(DB_FILE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(students, "\t")) # Pretty-printed JSON
	f.close()
