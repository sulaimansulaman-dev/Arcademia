extends Control

@onready var item_list: ItemList = $ColorRect/ItemList

var db_file_path = "user://students.json"

func _ready() -> void:
	# Load students from JSON and show them in the ItemList
	var students = load_students()

	# Clear any old items before adding
	item_list.clear()

	# Add all students as rows
	for student in students:
		var username = student.get("username", "unknown")
		var password = student.get("password", "unknown")
		item_list.add_item(username + " | " + password)


# --- JSON loader (same as your login script) ---
func load_students() -> Array:
	if FileAccess.file_exists(db_file_path):
		var file = FileAccess.open(db_file_path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(content)
		if parsed != null:
			return parsed
	return []


func _on_back_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_menuclose)
	get_tree().change_scene_to_file("res://avatar creation/scenes/LoginTeacher.tscn")


func _on_sign_out_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_menuclose)
	get_tree().change_scene_to_file("res://avatar creation/scenes/StudentTeacher.tscn")
