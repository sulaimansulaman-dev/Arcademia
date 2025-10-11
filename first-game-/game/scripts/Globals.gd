extends Node

var level_to_load: int = 1
var final_score: int = 0
var last_block_count: int = 0
var unlocked_levels: int = 0

var current_user: Dictionary = {}

@onready var level_1_score: int = 0
@onready var level_2_score: int = 0
@onready var level_3_score: int = 0
@onready var level_4_score: int = 0


func set_current_user(value: Dictionary) -> void:
	current_user = value
	_update_scores_from_user()


func get_current_user() -> Dictionary:
	return current_user


func _update_scores_from_user() -> void:
	if current_user.is_empty():
		level_1_score = 0
		level_2_score = 0
		level_3_score = 0
		level_4_score = 0
		unlocked_levels = 0
		return

	var scores: Dictionary = current_user.get("scores", {})
	level_1_score = int(scores.get("1", 0))
	level_2_score = int(scores.get("2", 0))
	level_3_score = int(scores.get("3", 0))
	level_4_score = int(scores.get("4", 0))
	unlocked_levels = int(current_user.get("unlocked_levels", 1))

	print("🌍 [Globals] Scores loaded from current_user:")
	for i in range(1, 5):
		print("  Level %d Score: %d" % [i, self["level_%d_score" % i]])
	print("  Unlocked Levels:", unlocked_levels)
