extends Node2D

@onready var webview: Control = $CanvasLayer/Control/VBoxContainer/WebView
@onready var game_area: Control = $CanvasLayer/Control/VBoxContainer/GameArea
@onready var game_viewport: Viewport = $CanvasLayer/Control/VBoxContainer/GameArea/GameViewport

var game_instance: Node = null
var player_node: Node2D = null

# store the last received Blockly program
var last_program: Array = []
var game_scene: PackedScene 


func _on_level_1_pressed() -> void:
	load("res://scenes/Level 1.tscn")

func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level 2.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()

func load_game() -> void:
	if game_instance:
		game_instance.queue_free()
		
	if Globals.level_to_load == 1:
		game_scene = load("res://scenes/Level 1.tscn")
	elif Globals.level_to_load == 2: 
		game_scene = load("res://scenes/Level 2.tscn")


	
	game_instance = game_scene.instantiate()
	game_viewport.add_child(game_instance)

	player_node = game_instance.get_node("Player")
	player_node.blockly_anchored = false

	# Tile alignment
	var ts = player_node.TILE_SIZE

	# Horizontal center
	player_node.position.x = int(player_node.position.x / ts) * ts + ts / 2

	# Vertical alignment (standing on top of tile)

	# Run cached program if exists
	if last_program.size() > 0:
		await _run_program(last_program)


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
	if data.get("type", "") == "program":
		var commands: Array = data.get("commands", []) as Array
		last_program = commands  # cache it
		await _run_program(commands)


func _run_program(commands: Array) -> void:
	for cmd_data in commands:
		var cmd: String = str(cmd_data.get("cmd", ""))
		var steps: int = int(cmd_data.get("steps", 1))
		await _move_player(cmd, steps)


func _move_player(cmd: String, steps: int) -> void:
	match cmd:
		"move_left":
			player_node.blockly_move(-1, steps)
			await player_node.blockly_step_done

		"move_right":
			player_node.blockly_move(1, steps)
			await player_node.blockly_step_done

		"move_up": # Jump
			player_node.blockly_jump()
			await get_tree().create_timer(0.4).timeout

		"move_down": # could be crouch later
			pass
