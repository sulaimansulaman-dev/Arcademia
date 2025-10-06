extends Node

@onready var sfx_menuopen = preload("res://music and sfx/sfx/menu_open.wav")
@onready var sfx_menuclose = preload("res://music and sfx/sfx/menu_close.wav")
@onready var sfx_save = preload("res://music and sfx/sfx/save.wav")


func play_sound(stream: AudioStream):
	var player = AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.play()

	# Wait for the sound to finish, then remove the player
	get_tree().create_timer(player.stream.get_length()).timeout.connect(func():
		player.queue_free()
	)
