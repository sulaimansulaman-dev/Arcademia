extends Control

@onready var item_list: ItemList = $ColorRect/ItemList

var db_file_path = "user://students.json"

func _ready() -> void:
	var students = load_students()

	item_list.clear()

	for student in students:
		var role = student.get("role", "")
		if role != "Student":
			continue  # skip anyone not a Student

		var username = student.get("username", "unknown")
		var password = student.get("password", "unknown")

		# Add the student's basic info
		item_list.add_item("👤 " + username + " | 🔑 " + password)

		# Add each level and score
		var scores = student.get("scores", {})
		for level in scores.keys():
			var score = scores[level]
			item_list.add_item("    Level " + str(level) + ": " + str(score))

		# Blank line for readability
		item_list.add_item("")


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

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/LoginTeacher.tscn")

func _on_sign_out_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/Start.tscn")


func _on_update_pressed() -> void:
	var students = load_students()
	
	# Get new values from the LineEdits
	var new_name = $nameEdit.text.strip_edges()
	var new_password = $ageEdit.text.strip_edges()
	
	check_empty($nameEdit)
	check_empty($ageEdit)
	# --- Validation: password must be exactly 5 digits ---
	if not new_password.is_valid_int() or new_password.length() != 5:
		var msg = AcceptDialog.new()
		msg.dialog_text = "⚠️ Password must be a 5-digit number!"
		get_tree().root.add_child(msg)
		msg.popup_centered()
		return
	
	var updated = false
	
	# Loop through all students and update matching one
	for student in students:
		if student.get("username", "") == new_name:
			student["password"] = new_password
			updated = true
			break
	
	if updated:
		# Save back to JSON
		var file = FileAccess.open(db_file_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(students, "\t"))  # nicely formatted JSON
		file.close()
		
		var msg = AcceptDialog.new()
		msg.dialog_text = "✅ Updated successfully!"
		get_tree().root.add_child(msg)
		msg.popup_centered()
	else:
		var msg = AcceptDialog.new()
		msg.dialog_text = "❌ Username not found!"
		get_tree().root.add_child(msg)
		msg.popup_centered()

	_ready()



func _on_delete_pressed() -> void:
	var students = load_students()
	var name_to_delete = $nameEdit.text.strip_edges()
	var found = false
	
	check_empty($nameEdit)
	
	
	# Filter out the student to delete
	var updated_students = []
	for student in students:
		if student.get("username", "") != name_to_delete:
			updated_students.append(student)
		else:
			found = true
	

	# Save the updated list back to the JSON file
	if found:
		var file = FileAccess.open(db_file_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(updated_students, "\t"))
		file.close()

		var msg = AcceptDialog.new()
		msg.dialog_text = "🗑️ Deleted " + name_to_delete + " successfully!"
		get_tree().root.add_child(msg)
		msg.popup_centered()
			
		# Refresh UI
		$nameEdit.clear()
		$ageEdit.clear()
		_ready()
	else:
		var msg = AcceptDialog.new()
		msg.dialog_text = "❌ Username not found!"
		get_tree().root.add_child(msg)
		msg.popup_centered()
	$nameEdit.clear()
	$ageEdit.clear()
	
func check_empty(le: LineEdit) -> bool:
	var text = le.text.strip_edges()  # remove leading/trailing spaces
	if text == "":
		# Optionally show a quick error
		var msg = AcceptDialog.new()
		msg.dialog_text = "⚠️ Name and Password Field cannot be empty!"
		get_tree().root.add_child(msg)
		msg.popup_centered()
		return true  # empty
	return false  # not empty
