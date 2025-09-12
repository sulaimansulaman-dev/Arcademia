extends Control  # or Node if MainMenu is not UI-based

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scenes/Blocks.tscn")
	Globals.level_to_load = 1

func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scenes/Level 2.tscn")
	Globals.level_to_load = 2


func _on_exit_pressed() -> void:
	get_tree().quit()
	
	
func _on_avatar_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/control.tscn")
