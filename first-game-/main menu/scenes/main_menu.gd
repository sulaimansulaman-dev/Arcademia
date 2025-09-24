extends Control


func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scenes/Level 1.tscn")


func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scenes/Level 2.tscn")


func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scenes/Level 3.tscn")


func _on_final_level_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scenes/Level 4.tscn")


func _on_exit_pressed() -> void:
	get_tree().exit()
