extends Control

var display_keys := []

@onready var name_input: LineEdit = $nameEdit
@onready var age_input: LineEdit = $ageEdit
@onready var level_input: LineEdit = $levelEdit

@onready var insert_button: Button = $Insert
@onready var update_button: Button = $Update
@onready var delete_button: Button = $Delete
@onready var student_list: ItemList = $ColorRect/ItemList

@onready var student_manager: Node = $StudentManager

func _ready():
	print("Test")
	#insert_button.connect("pressed", Callable(self, "_on_add_pressed"))
	update_button.connect("pressed", Callable(self, "_on_update_pressed"))
	delete_button.connect("pressed", Callable(self, "_on_delete_pressed"))
	student_list.connect("item_selected", Callable(self, "_on_item_selected"))
	
	student_manager.load_students()
	refresh_student_list()
	name_input.grab_focus()
	print("Student manager exists:", student_manager)

func refresh_student_list():
	student_list.clear()
	display_keys.clear()
	var key_list := []
	for k in student_manager.students.keys():
		key_list.append(int(k))
	key_list.sort()
	for id_int in key_list:
		display_keys.append(id_int)
		var s = student_manager.students[str(id_int)]
		print(s)
		student_list.add_item("%d - %s [Age: %d, Level: %d]" % [id_int, s["name"], s["age"], s["level"]])

#func _on_add_pressed():
	#name = name_input.text.strip_edges()
	#var age = int(age_input.text) if age_input.text != "" else 0
	#var grade = grade_input.text.strip_edges()
#
	#if name == "":
		#push_warning("Please enter a name")
		#return
	#student_manager.add_student(name, age, grade)
	#refresh_student_list()
	#name_input.text = ""
	#age_input.text = ""
	#grade_input.text = ""

func _on_update_pressed():
	var sel = student_list.get_selected_items()
	if sel.size() == 0:
		push_warning("Select a student to update")
		return
	var idx = sel[0]
	var id = display_keys[idx]
	name = name_input.text.strip_edges()
	var age = int(age_input.text) if age_input.text != "" else 0
	var level = int(level_input.text) if level_input.text != "" else 0
	if student_manager.update_student(id, name, age, level):
		refresh_student_list()
	else:
		push_warning("Failed to update student ID %d" % id)

func _on_delete_pressed():
	var sel = student_list.get_selected_items()
	if sel.size() == 0:
		push_warning("Select a student to delete")
		return
	var idx = sel[0]
	var id = display_keys[idx]
	if student_manager.delete_student(id):
		refresh_student_list()
	else:
		push_warning("Failed to delete student ID %d" % id)

func _on_item_selected(index: int) -> void:
	AudioManager.play_sound(AudioManager.sfx_nav)
	if index < 0 or index >= display_keys.size():
		return
	var id = display_keys[index]
	var s = student_manager.students[str(id)]
	name_input.text = str(s["name"])
	age_input.text = str(s["age"])
	level_input.text = str(s["level"])
