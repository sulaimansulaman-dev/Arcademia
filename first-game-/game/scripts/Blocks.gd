# blocks.gd
extends Node2D 

@onready var lvl1_webview: WebView = $CanvasLayer/Control/HSplitContainer/WebViewOverlay/Lvl1_Blockly
@onready var lvl2_webview: WebView = $CanvasLayer/Control/HSplitContainer/WebViewOverlay/Lvl2_Blockly
@onready var lvl3_webview: WebView = $CanvasLayer/Control/HSplitContainer/WebViewOverlay/Lvl3_Blockly
@onready var lvl4_webview: WebView = $CanvasLayer/Control/HSplitContainer/WebViewOverlay/Lvl4_Blockly
@onready var game_area: Control = $CanvasLayer/Control/HSplitContainer/GameAreaBottom
@onready var game_viewport: Viewport = $CanvasLayer/Control/HSplitContainer/GameAreaBottom/GameViewportBottom

var game_instance: Node = null
var player_node: Node2D = null

var last_program: Array = []
var program_running: bool = false

# --- New variables for idle detection
var last_player_pos: Vector2
var idle_time: float = 0.0
var idle_threshold: float = 2.0 # seconds before reload

func _ready() -> void:
	for wv in [lvl1_webview, lvl2_webview, lvl3_webview, lvl4_webview]:
		if wv:
			wv.visible = false
			if wv.has_signal("ipc_message"):
				wv.connect("ipc_message", Callable(self, "_on_web_view_ipc_message"))
	load_level_and_blocks()

func _process(delta: float) -> void:
	if program_running and player_node:
		if player_node.position == last_player_pos:
			idle_time += delta
			if idle_time >= idle_threshold:
				print("⚠️ Player stuck during program! Reloading level...")
				reload_level()
		else:
			idle_time = 0.0
			last_player_pos = player_node.position

func go_back() -> void:
	var menu_path = "res://avatar creation/Natashas_Stuff/main menu/scenes/MainMenu.tscn"
	if ResourceLoader.exists(menu_path):
		get_tree().change_scene_to_file(menu_path)
	else:
		push_error("❌ MainMenu scene not found at: " + menu_path)

func load_level_and_blocks() -> void:
	for wv in [lvl1_webview, lvl2_webview, lvl3_webview, lvl4_webview]:
		wv.visible = false
	match Globals.level_to_load:
		1:
			load_game("res://game/scenes/Level 1.tscn", true)
			lvl1_webview.visible = true
		2:
			lvl2_webview.visible = true
			load_game("res://game/scenes/Level 2.tscn", true)
		3:
			lvl3_webview.visible = true
			load_game("res://game/scenes/Level 3.tscn", true)
		4:
			lvl4_webview.visible = true
			load_game("res://game/scenes/Level 4.tscn", true)

func load_game(scene_path: String, run_last_program: bool = false) -> void:
	if game_instance:
		game_instance.queue_free()
	var game_scene = load(scene_path)
	game_instance = game_scene.instantiate()
	for child in game_viewport.get_children():
		child.queue_free()
	game_viewport.add_child(game_instance)
	player_node = game_instance.get_node("Player")
	var killzone = game_instance.get_node_or_null("Killzone")
	if killzone and not killzone.is_connected("player_died", reload_level):
		killzone.player_died.connect(reload_level)
	if player_node and player_node.has_method("TILE_SIZE"):
		var ts = player_node.TILE_SIZE
		player_node.position.x = int(player_node.position.x / ts) * ts + ts / 2
	if run_last_program and last_program.size() > 0:
		await _run_program(last_program)

func reload_level() -> void:
	Engine.time_scale = 1
	last_program.clear()
	program_running = false
	idle_time = 0.0
	last_player_pos = Vector2.ZERO
	load_level_and_blocks()

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

# --- Run program: delegate each command to _execute_command (keeps behavior consistent) ---
func _run_program(commands: Array) -> void:
	program_running = true
	idle_time = 0.0
	if player_node:
		last_player_pos = player_node.position
	# Execute every top-level command through the common executor (handles nesting)
	for cmd_data in commands:
		if not program_running:
			break
		await _execute_command(cmd_data)
	program_running = false

# --- Command executor (recursive, supports nested repeat/if/while) ---
func _execute_command(cmd_data: Dictionary) -> void:
	# Global guard: if program was stopped, bail out early.
	if not program_running:
		return

	var cmd: String = str(cmd_data.get("cmd", ""))
	# Movement commands
	if cmd in ["move_left","move_right","move_up","move_right_and_jump","move_down"]:
		var steps: int = int(cmd_data.get("steps", 1))
		await _move_player(cmd, steps)
		return

	# If / If-Else (they can contain statement lists)
	if cmd == "if":
		var cond: String = str(cmd_data.get("cond", ""))
		var do_cmds: Array = cmd_data.get("do", [])
		if _evaluate_condition(cond):
			for inner_cmd in do_cmds:
				if not program_running:
					return
				await _execute_command(inner_cmd)
		return

	if cmd == "if_else":
		var cond: String = str(cmd_data.get("cond", ""))
		var do_cmds: Array = cmd_data.get("do", [])
		var else_cmds: Array = cmd_data.get("else", [])
		if _evaluate_condition(cond):
			for inner_cmd in do_cmds:
				if not program_running:
					return
				await _execute_command(inner_cmd)
		else:
			for inner_cmd in else_cmds:
				if not program_running:
					return
				await _execute_command(inner_cmd)
		return

	# While loop
	if cmd == "while":
		var cond: String = str(cmd_data.get("cond", ""))
		var do_cmds: Array = cmd_data.get("do", [])
		if do_cmds.is_empty():
			print("⚠️ While loop with empty body - skipping to avoid spin.")
			return
		while _evaluate_condition(cond) and program_running:
			for inner_cmd in do_cmds:
				if not program_running:
					return
				await _execute_command(inner_cmd)
			# small yield so changes can occur in the world
			await get_tree().create_timer(1).timeout
		return

	# Repeat loop (fixed logic for nested repeats)
	if cmd == "repeat":
		var times: int = int(cmd_data.get("times", 1))
		var do_cmds: Array = cmd_data.get("do", [])
		if do_cmds.is_empty():
			# nothing to do
			return
		print("➡️ Enter repeat: times=", times, " body_len=", do_cmds.size())
		for i in range(times):
			if not program_running:
				return
			# run the body (which can contain nested repeats/ifs/etc)
			for inner_cmd in do_cmds:
				if not program_running:
					return
				await _execute_command(inner_cmd)
			# small delay between repeat iterations to let animations/physics run
			await get_tree().create_timer(1.0).timeout
		print("⬅️ Exit repeat")
		return

	# Unknown command
	print("⚠️ Unknown command in _execute_command -> ", cmd)

func _evaluate_condition(cond: String) -> bool:
	match cond:
		"gap_ahead":
			var r = not player_node.is_ground_ahead()
			print("Eval cond: gap_ahead -> ", r)
			return r
		"ground_ahead":
			var r = player_node.is_ground_ahead()
			print("Eval cond: ground_ahead -> ", r)
			return r
		"spaceship_part":
			return _spaceship_part_exists()
		_:
			print("Eval cond: unknown -> ", cond)
			return false

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
			await get_tree().create_timer(1).timeout
		"move_right_and_jump":
			player_node.blockly_move_and_jump(steps)
			await player_node.blockly_step_done
		"move_down":
			pass

# ---------- helper to detect spaceship parts ----------
func _spaceship_part_exists() -> bool:
	if not game_instance:
		return false
	var found = _find_spaceship_part(game_instance)
	print("🔎 spaceship parts exist? ->", found)
	return found

func _find_spaceship_part(node: Node) -> bool:
	for child in node.get_children():
		if child.is_in_group("spaceship_part"):
			print("   found spaceship part:", child.name)
			return true
		if child.get_child_count() > 0:
			if _find_spaceship_part(child):
				return true
	return false
