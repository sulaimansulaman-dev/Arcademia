extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	add_to_group("spaceship_part")  # ✅ Add this line

func _on_body_entered(body: Node2D) -> void:
	if not body or body.name != "Player":
		return

	if game_manager:
		game_manager.add_point()

	if animation_player:
		animation_player.play("pickup")

	$CollisionShape2D.disabled = true  # disable collisions
	await animation_player.animation_finished
	queue_free()  # remove the coin node from the scene
