extends Node

@onready var name_input: LineEdit = $VBoxContainer/VBoxContainer/DetailsContainer/UserDetailsContainer/lineEdit1
@onready var age_input: LineEdit = $VBoxContainer/HBoxContainer2/DetailsContainer/UserDetailsContainer/lineEdit2
@onready var grade_input: LineEdit = $VBoxContainer/HBoxContainer3/DetailsContainer/UserDetailsContainer/lineEdit3

@onready var insert_button: Button = $VBoxContainer/HBoxContainer3/DetailsContainer/UserDetailsContainer/Button
@onready var update_button: Button = $VBoxContainer/HBoxContainer3/DetailsContainer/UserDetailsContainer/Button2
@onready var delete_button: Button = $VBoxContainer/HBoxContainer3/DetailsContainer/UserDetailsContainer/Button3
@onready var student_list: ItemList = $StudentList

@onready var student_manager = $StudentManager

func _ready():
	
	$nameEdit.grab_focus()
	print("Insert button:", insert_button) 
	insert_button.pressed.connect(_on_add_pressed)
	update_button.pressed.connect(_on_update_pressed)
	delete_button.pressed.connect(_on_delete_pressed)
	
	student_manager.load_students()
	refresh_student_list()

func refresh_student_list():
	student_list.clear()
	for student in student_manager.students.values():
		student_list.add_item("%s (Age: %d, Grade: %s)" % [student["name"], student["age"], student["badge"]])

func _on_add_pressed():
	
	var name = name_input.text
	var age = int(age_input.text)
	var grade = grade_input.text
	
	student_manager.add_student(name, age, grade)
	refresh_student_list()

func _on_update_pressed():
	var selected = student_list.get_selected_items()
	if selected.size() > 0:
		var id = student_manager.students.keys()[selected[0]]
		var name = name_input.text
		var age = int(age_input.text)
		var grade = grade_input.text
		student_manager.update_student(id, name, age, grade)
		refresh_student_list()

func _on_delete_pressed():
	var selected = student_list.get_selected_items()
	if selected.size() > 0:
		var id = student_manager.students.keys()[selected[0]]
		student_manager.delete_student(id)
		refresh_student_list()
