# Killzone.gd
extends Area2D

signal player_died

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		AudioManager.play_sound(AudioManager.sfx_death)
		print("You Died!")
		Engine.time_scale = 0.5
		body.get_node("CollisionShape2D").queue_free()

		# reset time scale immediately before reload
		Engine.time_scale = 1

		var blocks_scene = get_tree().get_root().get_node("blocks") # adjust path
		if blocks_scene:
			blocks_scene.program_running = false

		call_deferred("emit_signal", "player_died")
