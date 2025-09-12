extends Node2D

@onready var webview: Control = $CanvasLayer/Control/HBoxContainer/WebView
@onready var game_area: Control = $CanvasLayer/Control/HBoxContainer/GameArea
@onready var game_viewport: Viewport = $CanvasLayer/Control/HBoxContainer/GameArea/GameViewport

var game_instance: Node = null
var player_node: Node2D = null

var last_program: Array = []
var game_scene: PackedScene
var program_running: bool = false   # 🔹 flag to track if a program is running


func _on_level_1_pressed() -> void:
	Globals.level_to_load = 1
	load_game(false)

func _on_level_2_pressed() -> void:
	Globals.level_to_load = 2
	load_game(false)

func _on_exit_pressed() -> void:
	get_tree().quit()


func load_game(run_last_program: bool = true) -> void:
	# Remove old game instance if exists
	if game_instance:
		game_instance.queue_free()

	# Load correct level
	if Globals.level_to_load == 1:
		game_scene = load("res://game/scenes/Level 1.tscn")
	elif Globals.level_to_load == 2:
		game_scene = load("res://game/scenes/Level 2.tscn")

	# Instantiate new game instance
	game_instance = game_scene.instantiate()

	# 🔹 Instead of adding fresh, remove children from viewport and add the new game
	for child in game_viewport.get_children():
		child.queue_free()
	game_viewport.add_child(game_instance)

	# Grab player
	player_node = game_instance.get_node("Player")

	# Connect Killzone safely
	var killzone = game_instance.get_node_or_null("Killzone")
	if killzone and not killzone.is_connected("player_died", reload_level):
		killzone.player_died.connect(reload_level)

	# Tile alignment
	var ts = player_node.TILE_SIZE
	player_node.position.x = int(player_node.position.x / ts) * ts + ts / 2

	# Only rerun program if allowed
	if run_last_program and last_program.size() > 0:
		await _run_program(last_program)



func reload_level() -> void:
	Engine.time_scale = 1        # reset time scale immediately
	last_program.clear()         # stop old commands
	program_running = false      # stop any running Blockly program
	load_game(false)             # reload the current level, do not rerun commands



func _ready() -> void:
	
	load_game()
	if webview.has_signal("ipc_message"):
		webview.ipc_message.connect(_on_web_view_ipc_message)
	print("GameArea size = ", game_area.size)


func _on_web_view_ipc_message(message: String) -> void:
	var result = JSON.parse_string(message)
	if typeof(result) != TYPE_DICTIONARY:
		return
	var data: Dictionary = result
	match data.get("type", ""):
		"program":
			var commands: Array = data.get("commands", []) as Array
			last_program = commands
			if not program_running:
				await _run_program(commands)
		"reset_level":
			reload_level()


func _run_program(commands: Array) -> void:
	program_running = true
	for cmd_data in commands:
		if not program_running:     # 🔹 exit if reset or death happened
			break
		var cmd: String = str(cmd_data.get("cmd", ""))
		var steps: int = int(cmd_data.get("steps", 1))
		await _move_player(cmd, steps)
		await get_tree().create_timer(0.3).timeout
	program_running = false


func _move_player(cmd: String, steps: int) -> void:
	match cmd:
		"move_left":
			player_node.blockly_move(-1, steps)
			await player_node.blockly_step_done
		"move_right":
			player_node.blockly_move(1, steps)
			await player_node.blockly_step_done
		"move_up":
			player_node.blockly_jump()
			await get_tree().create_timer(0.4).timeout
		"move_right_and_jump":
			player_node.blockly_move_and_jump(steps)
			await player_node.blockly_step_done
		"move_down":
			pass
