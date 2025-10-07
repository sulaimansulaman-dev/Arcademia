extends Node

@onready var sfx_menuopen = preload("res://music and sfx/sfx/menu_open.wav")
@onready var sfx_menuclose = preload("res://music and sfx/sfx/menu_close.wav")
@onready var sfx_save = preload("res://music and sfx/sfx/save.wav")
@onready var sfx_nav = preload("res://music and sfx/sfx/nav.wav")

func play_sound(stream: AudioStream, volume_db: float = -8.0):
	if not stream:
		return
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db  # allow adjustable volume
	add_child(player)
	player.play()

	# Free player after sound finishes
	get_tree().create_timer(stream.get_length()).timeout.connect(func():
		if is_instance_valid(player):
			player.queue_free()
	)
