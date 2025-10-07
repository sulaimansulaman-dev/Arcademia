extends Control

@onready var level_1_button: Button = $"Level 1"
@onready var level_2_button: Button = $"Level 2"
@onready var level_3_button: Button = $"Level 3"
@onready var final_level_button: Button = $"Final Level"
@onready var level_1_label: Label = $lblLevel1
@onready var level_2_label: Label = $lblLevel2
@onready var level_3_label: Label = $lblLevel3
@onready var level_4_label: Label = $lblLevel4


func _ready():
	if Globals.current_user.is_empty():
		print("⚠️ No logged-in user found. Redirecting to login...")
		get_tree().change_scene_to_file("res://avatar creation/scenes/StudentTeacher.tscn")
		return

	Globals._update_scores_from_user() # ensure labels always reflect latest data

	var unlocked_levels = Globals.unlocked_levels
	print("🎮 Logged in as:", Globals.current_user["username"], "| Unlocked Levels:", unlocked_levels)

	level_1_button.disabled = false
	level_2_button.disabled = unlocked_levels < 2
	level_3_button.disabled = unlocked_levels < 3
	final_level_button.disabled = unlocked_levels < 4

	load_labels()


func load_labels() -> void:
	for i in range(1, 5):
		var label: Label = get_node_or_null("lblLevel%d" % i)
		if label:
			label.text = "Score: " + str(Globals["level_%d_score" % i])
		else:
			print("⚠️ Could not find label: lblLevel%d" % i)


func _on_level_1_pressed() -> void:
	Globals.level_to_load = 1
	get_tree().change_scene_to_file("res://game/scenes/LevelIntro.tscn")

func _on_level_2_pressed() -> void:
	Globals.level_to_load = 2
	get_tree().change_scene_to_file("res://game/scenes/LevelIntro.tscn")

func _on_level_3_pressed() -> void:
	Globals.level_to_load = 3
	get_tree().change_scene_to_file("res://game/scenes/LevelIntro.tscn")

func _on_final_level_pressed() -> void:
	Globals.level_to_load = 4
	get_tree().change_scene_to_file("res://game/scenes/LevelIntro.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_sign_out_pressed() -> void:
	Globals.current_user = {}
	for i in range(1, 5):
		Globals["level_%d_score" % i] = 0
	get_tree().change_scene_to_file("res://avatar creation/scenes/StudentTeacher.tscn")
