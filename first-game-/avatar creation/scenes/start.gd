extends Node2D


func _on_student_button_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/LoginStudent.tscn")


func _on_teacher_button_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/LoginTeacher.tscn")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("back_action"):
		_on_back_button_pressed()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/Start.tscn")
