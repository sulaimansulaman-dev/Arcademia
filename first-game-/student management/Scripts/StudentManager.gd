extends Node

# -----------------------------
# Data
# -----------------------------
var students := {}
var next_id := 1

func _ready():
	load_students()

# -----------------------------
# CRUD
# -----------------------------
func add_student(name: String, age: int, badge: String) -> void:
	var id = next_id
	var student = {"id": id, "name": name, "age": age, "badge": badge}
	students[str(id)] = student   
	next_id += 1
	save_students()
	print("Current Students:", students)

func update_student(id: int, name: String, age: int, badge: String) -> bool:
	var key = str(id)
	if students.has(key):
		students[key]["name"] = name
		students[key]["age"] = age
		students[key]["badge"] = badge
		save_students()
		return true
	return false

func delete_student(id: int) -> bool:
	var key = str(id)
	if students.has(key):
		students.erase(key)
		save_students()
		return true
	return false

# -----------------------------
# Save / Load
# -----------------------------
func save_students() -> void:
	var f = FileAccess.open("user://students.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(students, "  ", true))
		f.close()
	else:
		push_error("Failed to open user://students.json for writing")

func load_students() -> void:
	if not FileAccess.file_exists("user://students.json"):
		return
	var f = FileAccess.open("user://students.json", FileAccess.READ)
	if f:
		var content = f.get_as_text()
		f.close()
		var parsed = JSON.parse_string(content)
		
		if typeof(parsed) == TYPE_DICTIONARY:
			students = parsed

			var max_id = 0
			for k in students.keys():
				var id_int = int(k)
				students[k]["id"] = id_int
				if id_int > max_id:
					max_id = id_int
			next_id = max_id + 1
		else:
			push_warning("Loaded JSON is not a Dictionary or invalid.")
	else:
		push_error("Failed to open user://students.json for reading")
