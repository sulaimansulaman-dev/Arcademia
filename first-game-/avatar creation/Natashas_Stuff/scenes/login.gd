extends Node2D

@onready var username_field : LineEdit = $NameEdit
@onready var password_field : LineEdit = $AgeEdit

var db_file_path = "user://students.json"

# When "Login" button pressed
func _on_save_button_2_pressed() -> void:
	var username = username_field.text
	var pwd = password_field.text

	var students = load_students()

	for student in students:
		if student["username"] == username and student["password"] == pwd:
			print("Password found ✅ for:", username)
			get_tree().change_scene_to_file("res://avatar creation/Natashas_Stuff/scenes/display.tscn")
			return

	print("Password not found ❌")


# --- JSON loader ---
func load_students() -> Array:
	if FileAccess.file_exists(db_file_path):
		var file = FileAccess.open(db_file_path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(content)
		if parsed != null:
			return parsed
	return []
