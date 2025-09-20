extends Control  # or Node if MainMenu is not UI-based

func _on_level_1_pressed() -> void:
	Globals.level_to_load = 1
	get_tree().change_scene_to_file("res://game/scenes/Blocks.tscn")

func _on_level_2_pressed() -> void:
	Globals.level_to_load = 2
	get_tree().change_scene_to_file("res://game/scenes/Blocks.tscn")
	
func _on_level_3_pressed() -> void:
	Globals.level_to_load = 3
	get_tree().change_scene_to_file("res://game/scenes/Blocks.tscn")
	
func _on_level_4_pressed() -> void:
	Globals.level_to_load = 4
	get_tree().change_scene_to_file("res://game/scenes/Blocks.tscn")
	

	
func _on_avatar_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/control.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
	


func _on_sign_up_pressed() -> void:
	get_tree().change_scene_to_file("res://avatar creation/scenes/Login.tscn")
