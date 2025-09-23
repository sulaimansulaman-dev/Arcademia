extends Node2D


func _on_save_button_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/StudentEntry.tscn")
