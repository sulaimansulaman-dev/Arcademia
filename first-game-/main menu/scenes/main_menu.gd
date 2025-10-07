extends Control

@onready var level_1_button: Button = $"Level 1"
@onready var level_2_button: Button = $"Level 2"
@onready var level_3_button: Button = $"Level 3"
@onready var final_level_button: Button = $"Final Level"



func _ready():
	#AudioManager.play_sound(AudioManager.bgm_mainmusic)
	# Disable buttons based on progress
	level_1_button.disabled = false
	level_2_button.disabled = Globals.unlocked_levels < 2
	level_3_button.disabled = Globals.unlocked_levels < 3
	final_level_button.disabled = Globals.unlocked_levels < 4

func _on_level_1_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_menuopen)
	Globals.level_to_load = 1
	get_tree().change_scene_to_file("res://game/scenes/LevelIntro.tscn")


func _on_level_2_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_menuopen)
	Globals.level_to_load = 2
	get_tree().change_scene_to_file("res://game/scenes/LevelIntro.tscn")


func _on_level_3_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_menuopen)
	Globals.level_to_load = 3
	get_tree().change_scene_to_file("res://game/scenes/LevelIntro.tscn")


func _on_final_level_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_menuopen)
	Globals.level_to_load = 4
	get_tree().change_scene_to_file("res://game/scenes/LevelIntro.tscn")

func _on_exit_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_menuclose)
	$sfx_menuclose.play()
	get_tree().quit()


func _on_sign_out_pressed() -> void:
	AudioManager.play_sound(AudioManager.sfx_menuclose)
	get_tree().change_scene_to_file("res://avatar creation/scenes/StudentTeacher.tscn")
