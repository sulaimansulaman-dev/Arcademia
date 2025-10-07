extends Node2D

func _ready():
	AudioManager.play_sound(AudioManager.bgm_mainmusic)

func _on_student_button_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_menuopen)
	get_tree().change_scene_to_file("res://avatar creation/scenes/LoginStudent.tscn")


func _on_teacher_button_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_menuopen)
	get_tree().change_scene_to_file("res://avatar creation/scenes/LoginTeacher.tscn")
