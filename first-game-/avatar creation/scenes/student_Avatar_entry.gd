extends Node2D

@onready var userName : LineEdit = $NameEdit
@onready var password : LineEdit = $PasswordEdit

var db_file_path = "user://students.json"  # database file

func _on_save_button_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_save)
	var username = userName.text.strip_edges()
	var pwd = password.text.strip_edges()

	# --- Validation ---
	if username == "" or pwd == "":
		AudioManager.play_sound(AudioManager.sfx_error)
		print("Error: Fields cannot be empty ❌")
		return

	# --- Create new student entry ---
	var new_student = {
		"username": username,
		"password": pwd
	}

	var students = load_students()

	# Prevent duplicate usernames
	for student in students:
		if student["username"] == username:
			print("Error: Username already exists ❌")
			return

	students.append(new_student)
	save_students(students)

	print("✅ Saved new student:", new_student)

	# Switch to main menu
	get_tree().change_scene_to_file("res://main menu/scenes/MainMenu.tscn")


# --- Helpers for database ---
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
