extends Node

# sound effects
@onready var sfx_menuopen = preload("res://game/assets/music and sfx/sfx/menu_open.wav")
@onready var sfx_menuclose = preload("res://game/assets/music and sfx/sfx/menu_close.wav")
@onready var sfx_save = preload("res://game/assets/music and sfx/sfx/save.wav")
@onready var sfx_nav = preload("res://game/assets/music and sfx/sfx/nav.wav")
@onready var sfx_error = preload("res://game/assets/music and sfx/sfx/error.wav")
@onready var sfx_optionselect = preload("res://game/assets/music and sfx/sfx/option_select.wav")
@onready var sfx_partfound = preload("res://game/assets/music and sfx/sfx/part_found.wav")
@onready var sfx_reload = preload("res://game/assets/music and sfx/sfx/reload.wav")
@onready var sfx_jump = preload("res://game/assets/music and sfx/sfx/jump.wav")
@onready var sfx_landing = preload("res://game/assets/music and sfx/sfx/landing.wav")
@onready var sfx_death = preload("res://game/assets/music and sfx/sfx/death.wav")
@onready var sfx_steps = [
	preload("res://game/assets/music and sfx/sfx/step_1.wav"),
	preload("res://game/assets/music and sfx/sfx/step_2.wav"),
	preload("res://game/assets/music and sfx/sfx/step_3.wav")
]

# background Music
@onready var bgm_main = preload("res://game/assets/music and sfx/music/Elys.mp3")
@onready var bgm_level_1 = preload("res://game/assets/music and sfx/music/astro.mp3")
@onready var bgm_level_2 = preload("res://game/assets/music and sfx/music/Moonriding.mp3")
@onready var bgm_level_3 = preload("res://game/assets/music and sfx/music/herotime.mp3")
@onready var bgm_level_4 = preload("res://game/assets/music and sfx/music/hope.mp3")

# variables
var bgm_player: AudioStreamPlayer
var current_music: AudioStream = null
var level_music_list: Array
var last_level_track: AudioStream = null
var track_queue: Array = []

func _ready():
	print("🎵 AudioManager ready and running.")

	# prepare level music list
	level_music_list = [bgm_level_1, bgm_level_2, bgm_level_3, bgm_level_4]
	_reset_track_queue()  # initialize the queue
	randomize()  # ensure randomness

	# create audio player
	if not bgm_player:
		bgm_player = AudioStreamPlayer.new()
		bgm_player.autoplay = false
		bgm_player.volume_db = -10
		add_child(bgm_player)

	# connect to scene changes
	if not get_tree().is_connected("scene_changed", Callable(self, "_on_scene_changed")):
		get_tree().scene_changed.connect(Callable(self, "_on_scene_changed"))

	# start playing appropriate music
	_on_scene_changed()

# plays sound effects
func play_sound(stream: AudioStream, volume_db: float = -8.0):
	if not stream:
		return
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	player.play()
	get_tree().create_timer(stream.get_length()).timeout.connect(func(): player.queue_free())

# plays background music
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

	# Looping
	if bgm_player.stream is AudioStreamWAV:
		bgm_player.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif bgm_player.stream is AudioStreamOggVorbis or bgm_player.stream is AudioStreamMP3:
		bgm_player.stream.loop = true

# stop background music ---
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

	var scene_name = scene.name
	print("🎬 Scene changed to:", scene_name)

	match scene_name:
		"Start", "StudentTeacher", "Login", "LoginStudent", "MainMenu", "LevelIntro", "SignUp", "AvatarCreation", "LevelOutro":
			play_music(bgm_main)

		# Any level or block scene
		"Level 1", "Level 2", "Level 3", "Level 4", "Game", "blocks":
			var chosen_track = get_random_level_track()
			play_music(chosen_track)

		_:
			play_music(bgm_main)

# --- helper: refill and shuffle the queue when empty
func _reset_track_queue():
	track_queue = level_music_list.duplicate()
	track_queue.shuffle()

# --- new improved random track logic (no repeats until all played)
func get_random_level_track() -> AudioStream:
	if track_queue.is_empty():
		_reset_track_queue()

	var next_track = track_queue.pop_front()
	track_queue.append(next_track)  # move played song to the back
	last_level_track = next_track
	return next_track
