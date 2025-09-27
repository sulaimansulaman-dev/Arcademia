#extends Control
#
#var students := {}
#var next_id = 1
#
#@onready var student_list: ItemList = $ColorRect/ItemList
#@onready var insert_button: Button = $VBoxContainer/Insert
#@onready var update_button: Button = $VBoxContainer/Update
#@onready var delete_button: Button = $VBoxContainer/Delete
#
#@onready var name_input: LineEdit = $VBoxContainer/nameEdit
#@onready var age_input: LineEdit = $VBoxContainer/ageEdit
#@onready var grade_input: LineEdit = $VBoxContainer/badgeEdit
#
#@onready var StudentManager = $StudentManager
#
#func _ready():
	#insert_button.pressed.connect(_on_insert_pressed)
	#update_button.pressed.connect(_on_update_pressed)
	#delete_button.pressed.connect(_on_delete_pressed)
	#
	#StudentManager.load_students()
	#
	#refresh_student_list()
	#print(OS.get_user_data_dir())
#
#func refresh_student_list():
	#student_list.clear()
	#for student in StudentManager.students.values():
		#student_list.add_item(
			#"%s | Age: %d | Grade: %s" % [student["name"], student["age"], student["badge"]]
		#)
#
#func _on_insert_pressed():
	#var name = name_input.text
	#var age = int(age_input.text)
	#var badge = grade_input.text
#
	#StudentManager.add_student(name, age, badge)  
	#refresh_student_list()
#
#func _on_update_pressed():
	#var selected = student_list.get_selected_items()
	#if selected.size() > 0:
		#var id = StudentManager.students.keys()[selected[0]]
		#StudentManager.update_student(id, "Updated Name", 13, "8th")
		#refresh_student_list()
#
#func _on_delete_pressed():
	#var selected = student_list.get_selected_items()
	#if selected.size() > 0:
		#var id = StudentManager.students.keys()[selected[0]]
		#StudentManager.delete_student(id)
		#refresh_student_list()
#
#func load_students():
	#if FileAccess.file_exists("user://students.json"):
		#var file = FileAccess.open("user://students.json", FileAccess.READ)
		#if file:
			#var content = file.get_as_text()
			#var data = JSON.parse_string(content)
			#if typeof(data) == TYPE_DICTIONARY:
				#students = data
				#if students.size() > 0:
					#next_id = int(students.keys().max()) + 1
			#file.close()
	#print(OS.get_user_data_dir())
