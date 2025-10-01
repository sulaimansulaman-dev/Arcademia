extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	add_to_group("spaceship_part") 

func _on_body_entered(Body:Node2D) -> void:
	game_manager.add_point()
	
	animation_player.play("pickup")
	get_tree().change_scene_to_file("res://game/scenes/LevelOutro.tscn")
