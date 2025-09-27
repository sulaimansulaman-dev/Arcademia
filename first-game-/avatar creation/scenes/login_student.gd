extends Node2D

@onready var userName : LineEdit = $NameEdit
@onready var password : LineEdit = $Password

var db_file_path = "user://students.json"


func _on_save_button_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/control.tscn")

func _on_save_button_2_pressed() -> void:
	var username = userName.text.strip_edges()
	var pwd = password.text.strip_edges()
	
	# 🔹 Check if fields are empty
	if username.is_empty() or pwd.is_empty():
		print("⚠️ Username and Password cannot be empty")
		return

	var students = load_students()
	
	# 🔹 Check each student
	for student in students:
		if student["username"] == username and student["password"] == pwd:
			print("✅ Password correct for:", username)
			get_tree().change_scene_to_file("res://main menu/scenes/MainMenu.tscn")
			return
	
	# 🔹 If no student matched
	print("❌ Wrong username or password. Try again")
	password.text = ""  # clear password field

func load_students() -> Array:
	if FileAccess.file_exists(db_file_path):
		var file = FileAccess.open(db_file_path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(content)
		if parsed != null:
			return parsed
	return []
