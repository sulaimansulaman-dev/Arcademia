extends Node

# Sound Effects
@onready var sfx_menuopen = preload("res://music and sfx/sfx/menu_open.wav")
@onready var sfx_menuclose = preload("res://music and sfx/sfx/menu_close.wav")
@onready var sfx_save = preload("res://music and sfx/sfx/save.wav")
@onready var sfx_nav = preload("res://music and sfx/sfx/nav.wav")
@onready var sfx_error = preload("res://music and sfx/sfx/error.wav")

# Background Music
@onready var bgm_mainmusic = preload("res://music and sfx/music/Elys.mp3")
#@onready var bgm_level1 = preload("res://music and sfx/music/level1_theme.ogg")
#@onready var bgm_level2 = preload("res://music and sfx/music/level2_theme.ogg")
#@onready var bgm_level3 = preload("res://music and sfx/music/level3_theme.ogg")
@onready var bgm_level4 = preload("res://music and sfx/music/Moonriding.mp3")

# Background music player
var bgm_player: AudioStreamPlayer

func _ready():
	bgm_player = AudioStreamPlayer.new()
	bgm_player.volume_db = -10
	add_child(bgm_player)

#Play SFX (One-Shot)
func play_sound(stream: AudioStream, volume_db: float = -8.0):
	if not stream:
		return
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	player.play()

	# Free after finish
	get_tree().create_timer(stream.get_length()).timeout.connect(func():
		if is_instance_valid(player):
			player.queue_free()
	)

# Play Background Music

func play_music(stream: AudioStream, volume_db: float = -10.0):
	if not stream:
		return
	if bgm_player.stream == stream:
		return # already playing this one

	bgm_player.stop()
	# If the stream supports looping, enable it
	if stream is AudioStreamWAV:
		stream.loop = true

	bgm_player.stream = stream
	bgm_player.volume_db = volume_db
	bgm_player.play()
	
	

# Optional fade-out (smooth transition)
func stop_music(fade_time: float = 1.0):
	if not bgm_player.playing:
		return
	var tween = create_tween()
	tween.tween_property(bgm_player, "volume_db", -40, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func():
		bgm_player.stop()
		bgm_player.volume_db = -10)
