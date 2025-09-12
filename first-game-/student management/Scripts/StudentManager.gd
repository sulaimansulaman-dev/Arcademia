extends Node

var students := {}   # Dictionary of students
var next_id := 1     # Auto-increment ID

# -----------------------------
# CRUD FUNCTIONS
# -----------------------------
func add_student(name: String, age: int, badge: String):
	var student = {
		"id": next_id,
		"name": name,
		"age": age,
		"badge": badge,
	}
	students[next_id] = student
	next_id += 1
	save_students()

func update_student(id: int, name: String, age: int, grade: String):
	if students.has(id):
		students[id]["name"] = name
		students[id]["age"] = age
		students[id]["grade"] = grade
		save_students()

func delete_student(id: int):
	if students.has(id):
		students.erase(id)
		save_students()

# -----------------------------
# SAVE / LOAD TO FILE
# -----------------------------
func save_students():
	var file = FileAccess.open("user://students.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(students, "  ", true))
		file.close()

func load_students():
	if FileAccess.file_exists("user://students.json"):
		var file = FileAccess.open("user://students.json", FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var data = JSON.parse_string(content)
			if typeof(data) == TYPE_DICTIONARY:
				students = data
				if students.size() > 0:
					next_id = int(students.keys().max()) + 1
			file.close()
	print(OS.get_user_data_dir())
	#else:
		# Dummy students for test
		#add_student("Alice", 14, "9th", 1)
	#	add_student("Bob", 15, "10th", 2)
	#	add_student("Charlie", 16, "11th", 3)
		
		
