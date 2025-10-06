extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	add_to_group("spaceship_part") 

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var used_blocks = Globals.last_block_count
		var max_blocks = 10
		# Score formula: fewer blocks = higher score
		var score = 10 - int((float(used_blocks - 5) / (max_blocks - 5)) * 9)
		score = clamp(score, 1, 10)

		# GameManager.set_final_score(score)
		GameManager.set_final_score(used_blocks)
		print("✅ Coin collected! Blocks used (Score): ", used_blocks)

		animation_player.play("pickup")

		get_tree().change_scene_to_file("res://game/scenes/LevelOutro.tscn")
