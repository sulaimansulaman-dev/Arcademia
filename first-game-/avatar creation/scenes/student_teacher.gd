extends Node2D


func _on_start_button_1_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_menuopen)
	get_tree().change_scene_to_file("res://avatar creation/scenes/Start.tscn")
