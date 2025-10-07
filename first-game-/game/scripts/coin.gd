extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var db_file_path: String = "user://students.json"

func _ready() -> void:
	add_to_group("spaceship_part")
	get_scores_1_to_4_separately()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	var used_blocks: int = Globals.last_block_count
	var max_blocks: int = 10

	# Calculate score: fewer blocks = higher score
	var score: int = 10 - int((float(used_blocks - 5) / (max_blocks - 5)) * 9)
	score = clamp(score, 1, 10)

	GameManager.set_final_score(used_blocks)
	print("✅ Coin collected! Blocks used (Score): ", used_blocks)

	animation_player.play("pickup")

	# Save progress for logged-in student
	save_player_progress(Globals.level_to_load, used_blocks)

	# Go to outro screen
	get_tree().change_scene_to_file("res://game/scenes/LevelOutro.tscn")


func save_player_progress(level: int, score: int) -> void:
	if Globals.current_user.is_empty():
		print("⚠️ No user logged in! Cannot save progress.")
		return

	var students: Array = load_students()
	for student in students:
		if student.get("username", "") == Globals.current_user.get("username", ""):
			# ensure "scores" exists and is a Dictionary
			if not student.has("scores") or typeof(student["scores"]) != TYPE_DICTIONARY:
				student["scores"] = {}

			# store/update the score for this level
			student["scores"][str(level)] = score

			# explicitly type and cast old_unlocked to avoid inference warning/error
			var old_unlocked: int = int(student.get("unlocked_levels", 1))
			student["unlocked_levels"] = max(old_unlocked, level + 1)

			# update the runtime current user
			Globals.current_user = student

			print("💾 Progress saved for:", student["username"])
			print("   Scores:", student["scores"])
			print("   Unlocked Levels:", student["unlocked_levels"])
			break

	save_students(students)


func load_students() -> Array:
	if not FileAccess.file_exists(db_file_path):
		return []

	var file := FileAccess.open(db_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()

	# Parse JSON safely (no explicit type, fully compatible)
	var parse_res = JSON.parse_string(content)
	if parse_res == null:
		print("⚠️ Failed to parse students.json (invalid JSON).")
		return []

	# Expecting an array at top level
	if typeof(parse_res) == TYPE_ARRAY:
		return parse_res
	else:
		print("⚠️ students.json parsed but top-level is not an Array. Found type:", typeof(parse_res))
		return []


func save_students(students: Array) -> void:
	var file := FileAccess.open(db_file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(students, "\t"))
	file.close()
	print("📂 Database updated successfully.")
	
func get_scores_1_to_4_separately() -> void:
	if Globals.current_user.is_empty():
		print("⚠️ No user logged in! Cannot retrieve scores.")
		return

	var student_scores: Dictionary = Globals.current_user.get("scores", {})

	# Loop through levels 1 to 4 and store in Globals
	for level in range(1, 5):
		Globals["level_%d_score" % level] = int(student_scores.get(str(level), 0))

	# Optional: print for debugging
	print("🎯 Scores:")
	for level in range(1, 5):
		print("Level %d: %d" % [level, Globals["level_%d_score" % level]])
