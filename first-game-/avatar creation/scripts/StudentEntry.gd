extends Node

@onready var name_input : LineEdit = $NameEdit
@onready var age_input : LineEdit = $AgeEdit


func _on_save_pressed():
	AudioManager.play_sound(AudioManager.sfx_save)
	name = name_input.text.strip_edges()
	var age = int(age_input.text) if age_input.text != "" else 0

	if name == "":
		push_warning("Please enter a name")
		return
	if age == null:
		push_warning("Enter a value")
		
	name_input.text = ""
	age_input.text = ""
	get_tree().change_scene_to_file("res://main menu/scenes/MainMenu.tscn")
	
	
