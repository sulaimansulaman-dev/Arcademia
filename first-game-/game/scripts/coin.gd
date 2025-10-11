extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var db_file_path: String = "user://students.json"


func _ready() -> void:
	add_to_group("spaceship_part")


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	var used_blocks: int = Globals.last_block_count
	GameManager.set_final_score(used_blocks)
	print("✅ Coin collected! Blocks used (Score): ", used_blocks)
	
	AudioManager.play_sound(AudioManager.sfx_partfound)

	animation_player.play("pickup")

	# Save progress for logged-in student
	save_player_progress(Globals.level_to_load, used_blocks)

	# Go to outro screen after physics step
	call_deferred("_go_to_outro")

func _go_to_outro() -> void:
	get_tree().change_scene_to_file("res://game/scenes/LevelOutro.tscn")



func save_player_progress(level: int, score: int) -> void:
	if Globals.current_user.is_empty():
		print("⚠️ No user logged in! Cannot save progress.")
		return

	var students: Array = load_students()
	for student in students:
		if student.get("username", "") == Globals.current_user.get("username", ""):
			if not student.has("scores") or typeof(student["scores"]) != TYPE_DICTIONARY:
				student["scores"] = {}

			# store/update the score for this level
			student["scores"][str(level)] = score

			# unlock next level
			var old_unlocked: int = int(student.get("unlocked_levels", 1))
			student["unlocked_levels"] = max(old_unlocked, level + 1)

			# update runtime current user (auto-refreshes Globals)
			Globals.set_current_user(student)

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

	var parse_res = JSON.parse_string(content)
	if parse_res == null:
		print("⚠️ Failed to parse students.json (invalid JSON).")
		return []

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
