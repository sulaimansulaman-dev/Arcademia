extends Control  # or Node if MainMenu is not UI-based

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level2.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
