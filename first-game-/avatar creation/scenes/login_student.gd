extends Node2D

@onready var userName : LineEdit = $NameEdit
@onready var password : LineEdit = $Password

var db_file_path = "user://students.json" 


func _on_save_button_pressed() -> void:
	get_tree().change_scene_to_file("res://student management/Scene/display.tscn")
	


func _on_save_button_2_pressed() -> void:
	var username = userName.text
	var pwd = password.text
	var students = load_students()

	for student in students:
		if student["username"] == username and student["password"] == pwd:
			print("Password found ✅ for:", username)
			print("Tree:", get_tree())
			print("Changing scene...")
			
			get_tree().change_scene_to_file("res://student management/Scene/display.tscn")
			return
			
		else: print("Wrong Password. Try again")
	


func load_students() -> Array:
	if FileAccess.file_exists(db_file_path):
		var file = FileAccess.open(db_file_path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(content)
		if parsed != null:
			return parsed
	return []
