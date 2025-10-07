extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.stop_music(1.0)
	AudioManager.play_music(AudioManager.bgm_level4)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
