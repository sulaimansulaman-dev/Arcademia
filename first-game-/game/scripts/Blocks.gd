extends Node2D

@onready var lvl1_webview: WebView = $CanvasLayer/Control/HSplitContainer/WebViewOverlay/Lvl1_Blockly
@onready var lvl2_webview: WebView = $CanvasLayer/Control/HSplitContainer/WebViewOverlay/Lvl2_Blockly
@onready var lvl3_webview: WebView = $CanvasLayer/Control/HSplitContainer/WebViewOverlay/Lvl3_Blockly
@onready var lvl4_webview: WebView = $CanvasLayer/Control/HSplitContainer/WebViewOverlay/Lvl4_Blockly
@onready var game_area: Control = $CanvasLayer/Control/HSplitContainer/VSplitContainer/GameAreaBottom
@onready var game_viewport: Viewport = $CanvasLayer/Control/HSplitContainer/VSplitContainer/GameAreaBottom/GameViewportBottom

var game_instance: Node = null
var player_node: Node2D = null

var last_program: Array = []
var program_running: bool = false


func _ready() -> void:
	# Hide all WebViews initially
	for wv in [lvl1_webview, lvl2_webview, lvl3_webview, lvl4_webview]:
		if wv:
			wv.visible = false
			# Connect safely using Callable
			if wv.has_signal("ipc_message"):
				wv.connect("ipc_message", Callable(self, "_on_web_view_ipc_message"))

	# Load current level
	load_level_and_blocks()

# -----------------------
# 🔹 Go back to main menu
func go_back() -> void:
	var menu_path = "res://main menu/scenes/MainMenu.tscn"
	if ResourceLoader.exists(menu_path):
		get_tree().change_scene_to_file(menu_path)
	else:
		push_error("❌ MainMenu scene not found at: " + menu_path)


func load_level_and_blocks() -> void:
	# Hide all first
	for wv in [lvl1_webview, lvl2_webview, lvl3_webview, lvl4_webview]:
		wv.visible = false

	match Globals.level_to_load:
		1:
			load_game("res://game/scenes/level_1.tscn", true)
			lvl1_webview.visible = true
			
		2:
			lvl2_webview.visible = true
			load_game("res://game/scenes/level_2.tscn", true)
		3:
			lvl3_webview.visible = true
			load_game("res://game/scenes/level_3.tscn", true)
		4:
			lvl4_webview.visible = true
			load_game("res://game/scenes/level_4.tscn", true)


# 🔹 Loads the actual game scene into the viewport
func load_game(scene_path: String, run_last_program: bool = false) -> void:
	if game_instance:
		game_instance.queue_free()

	var game_scene = load(scene_path)
	game_instance = game_scene.instantiate()

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
	if player_node and player_node.has_method("TILE_SIZE"):
		var ts = player_node.TILE_SIZE
		player_node.position.x = int(player_node.position.x / ts) * ts + ts / 2

	# Rerun program if allowed
	if run_last_program and last_program.size() > 0:
		await _run_program(last_program)


# 🔹 Reloads current level without resetting Blockly
func reload_level() -> void:
	Engine.time_scale = 1
	last_program.clear()
	program_running = false
	load_level_and_blocks()


# 🔹 WebView messages
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
		"back":
			go_back()
			
		


# 🔹 Run Blockly program
func _run_program(commands: Array) -> void:
	program_running = true
	for cmd_data in commands:
		if not program_running:
			break
		var cmd: String = str(cmd_data.get("cmd", ""))
		var steps: int = int(cmd_data.get("steps", 1))
		await _move_player(cmd, steps)
		await get_tree().create_timer(0.3).timeout
	program_running = false


# 🔹 Move player
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
