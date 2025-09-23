extends Node2D


func _on_student_button_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/control.tscn")


func _on_teacher_button_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/Login.tscn")
