extends Node

# sound effects variables
@onready var sfx_menuopen = preload("res://music and sfx/sfx/menu_open.wav")
@onready var sfx_menuclose = preload("res://music and sfx/sfx/menu_close.wav")
@onready var sfx_save = preload("res://music and sfx/sfx/save.wav")
@onready var sfx_nav = preload("res://music and sfx/sfx/nav.wav")

# background music variables
@onready var bgm_main = preload("res://music and sfx/music/Elys.mp3")
@onready var bgm_level_1 = preload("res://music and sfx/music/Moonriding.mp3")
@onready var bgm_level_2 = preload("res://music and sfx/music/dwm.mp3")
@onready var bgm_level_3 = preload("res://music and sfx/music/lasthope.mp3")
@onready var bgm_level_4 = preload("res://music and sfx/music/refreshed.mp3")

# music players
var bgm_player: AudioStreamPlayer
var current_music: AudioStream = null

func _ready():
	print("🎵 AudioManager ready and running.")

	if not bgm_player:
		bgm_player = AudioStreamPlayer.new()
		bgm_player.autoplay = false
		bgm_player.volume_db = -10
		add_child(bgm_player)

	# ✅ Use 'scene_changed' — this is correct in Godot 4.x
	if not get_tree().is_connected("scene_changed", Callable(self, "_on_scene_changed")):
		get_tree().scene_changed.connect(Callable(self, "_on_scene_changed"))

	# ✅ Play for the current scene when the game loads
	_on_scene_changed()

# playing the sound effects
func play_sound(stream: AudioStream, volume_db: float = -8.0):
	if not stream:
		return
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	player.play()
	get_tree().create_timer(stream.get_length()).timeout.connect(func(): player.queue_free())

# play background music
func play_music(stream: AudioStream, fade_time: float = 1.0):
	if not stream:
		return
	if current_music == stream:
		return

	current_music = stream

	if bgm_player.playing:
		stop_music(fade_time)
		await get_tree().create_timer(fade_time).timeout

	bgm_player.stream = stream
	bgm_player.bus = "Music" if AudioServer.get_bus_index("Music") != -1 else "Master"
	bgm_player.volume_db = -10
	bgm_player.play()

	# loop music
	if bgm_player.stream is AudioStreamWAV:
		bgm_player.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif bgm_player.stream is AudioStreamOggVorbis or bgm_player.stream is AudioStreamMP3:
		bgm_player.stream.loop = true

# stop background music
func stop_music(fade_out_time: float = 0.0):
	if fade_out_time > 0.0:
		var tween = create_tween()
		tween.tween_property(bgm_player, "volume_db", -80, fade_out_time)
		tween.finished.connect(func():
			bgm_player.stop()
			bgm_player.volume_db = -10)
	else:
		bgm_player.stop()

# handle scene changes
func _on_scene_changed():
	await get_tree().create_timer(0.05).timeout

	var scene = get_tree().current_scene
	if not scene:
		return

	print("Scene changed to:", scene.name)

	match scene.name:
		"Start", "StudentTeacher", "Login", "LoginStudent", "MainMenu", "LevelIntro", "SignUp", "AvatarCreation", "LevelOutro":
			play_music(bgm_main)
		"Level 1", "Game", "blocks":
			play_music(bgm_level_1)
		"Level 2":
			play_music(bgm_level_2)
		"Level 3":
			play_music(bgm_level_3)
		"Level 4":
			play_music(bgm_level_4)
		_:
			play_music(bgm_main)
