extends Node

@onready var save_button : Button = $SaveButton

@onready var name_input : LineEdit = $NameEdit
@onready var age_input : LineEdit = $AgeEdit

@onready var student_manager : Node = $StudentManager 

func _ready():
	print("Test")
	save_button.connect("pressed", Callable(self, "_on_save_pressed"))

func _on_save_pressed():
	name = name_input.text.strip_edges()
	var age = int(age_input.text) if age_input.text != "" else 0

	if name == "":
		push_warning("Please enter a name")
		return
	if age == null:
		push_warning("Enter a value")
		
	student_manager.add_student(name, age, 0)
	name_input.text = ""
	age_input.text = ""
	
	print(student_manager.students)
	
