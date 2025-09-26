extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:

	game_manager.add_point()
	animation_player.play("pickup")
<<<<<<< Updated upstream
	get_tree().change_scene_to_file("res://story1/toets1.tscn")
	
=======

	# Tiny delay so pickup anim/sound doesn’t get cut off
	await get_tree().create_timer(0.3).timeout

	get_tree().change_scene_to_file("res://game/scenes/LevelOutro.tscn")
>>>>>>> Stashed changes
