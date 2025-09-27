extends Node2D

@onready var userName : LineEdit = $Username
@onready var password : LineEdit = $password
@onready var passwordConfirm : LineEdit = $passwordCon

var db_file_path = "user://students.json"  # File will be created automatically if missing

func _on_save_button_pressed() -> void:
	var username = userName.text
	var pwd = password.text
	var confirm_pwd = passwordConfirm.text

	# Check if passwords match
	if pwd != confirm_pwd:
		print("Passwords do not match")
		return

	# Create new student entry
	var new_student = {
		"username": username,
		"password": pwd
	}
	var students = load_students()
	students.append(new_student)
	save_students(students)
	print("Saved new student:", new_student)
	get_tree().change_scene_to_file("res://avatar creation/scenes/control.tscn")


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
