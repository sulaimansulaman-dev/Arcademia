extends Node

@onready var name_input: LineEdit = $VBoxContainer/HBoxContainer/NameInput
@onready var age_input: LineEdit = $VBoxContainer/HBoxContainer2/AgeInput
@onready var grade_input: LineEdit = $VBoxContainer/HBoxContainer3/GradeInput

@onready var add_button: Button = $VBoxContainer/AddButton
@onready var update_button: Button = $VBoxContainer/UpdateButton
@onready var delete_button: Button = $VBoxContainer/DeleteButton
@onready var student_list: ItemList = $StudentList

func _ready():
	# Connect button signals
	add_button.pressed.connect(_on_add_pressed)
	update_button.pressed.connect(_on_update_pressed)
	delete_button.pressed.connect(_on_delete_pressed)

	# Load any saved students
	StudentManager.load_students()
	refresh_student_list()

func refresh_student_list():
	student_list.clear()
	for student in StudentManager.students.values():
		student_list.add_item("%s (Age: %d, Grade: %s)" % [student.name, student.age, student.grade])

func _on_add_pressed():
	var name = name_input.text
	var age = int(age_input.text)
	var grade = grade_input.text
	StudentManager.add_student(name, age, grade)
	refresh_student_list()

func _on_update_pressed():
	var selected = student_list.get_selected_items()
	if selected.size() > 0:
		var id = StudentManager.students.keys()[selected[0]]
		var name = name_input.text
		var age = int(age_input.text)
		var grade = grade_input.text
		StudentManager.update_student(id, name, age, grade)
		refresh_student_list()

func _on_delete_pressed():
	var selected = student_list.get_selected_items()
	if selected.size() > 0:
		var id = StudentManager.students.keys()[selected[0]]
		StudentManager.delete_student(id)
		refresh_student_list()


extends Node

var students := {}   # Dictionary of students
var next_id := 1     # Auto-increment ID

# -----------------------------
# CRUD FUNCTIONS
# -----------------------------
func add_student(name: String, age: int, grade: String):
	var student = {
		"id": next_id,
		"name": name,
		"age": age,
		"grade": grade
	}
	students[next_id] = student
	next_id += 1
	save_students()

func update_student(id: int, name: String, age: int, grade: String):
	if students.has(id):
		students[id].name = name
		students[id].age = age
		students[id].grade = grade
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
		file.store_string(JSON.stringify(students))
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

# -----------------------------
# Dummy_Database
# -----------------------------

extends Node

@onready var student_manager = $StudentManager

func _ready():
	
create_dummy_students()
print("Current students:", student_manager.students)

func create_dummy_students():
	# Clear any existing data
	student_manager.students.clear()
	student_manager.next_id = 1

adding dummy students
student_manager.add_student("Alice", 9, "3rd", 3, 1)
student_manager.add_student("Bob", 9, "3rd", 2, 2)
student_manager.add_student("Charlie", 10, "4th", 2, 1)
student_manager.add_student("SomeoneSomewhere", 8, "2nd", 1, 2)

student_manager.save_students()

print("Dummy students.json created at:", OS.get_user_data_dir())
