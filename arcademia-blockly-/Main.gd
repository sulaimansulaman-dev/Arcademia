extends Node2D

@onready var webview: Control = $CanvasLayer/Control/VBoxContainer/WebView
@onready var game_area: Control = $CanvasLayer/Control/VBoxContainer/GameArea

var game_instance: Node = null
var player_node: Node2D = null;
var player_target: Vector2

func _ready() -> void:
	# Instance the game scene
	var game_scene: PackedScene = load("res://World.tscn")
	game_instance = game_scene.instantiate()
	game_area.add_child(game_instance)
	player_node = game_instance.get_node("Player")
	player_target = player_node.position
	#Connect the Web View
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
		await _run_program(commands)

func _run_program(commands: Array) -> void:
	for cmd_data in commands:
		var cmd: String = str(cmd_data.get("cmd", ""))
		var steps: int = int(cmd_data.get("steps", 1))
		await _move_player(cmd, steps)

func _move_player(cmd: String, steps: int) -> void:
	var step_px: int = 32

	match cmd:
		"move_left":
			player_target.x -= steps * step_px
		"move_right":
			player_target.x += steps * step_px
		"move_up":
			player_target.y -= steps * step_px
		"move_down":
			player_target.y += steps * step_px
			

		# Just clamp inside GameArea bounds (ignore player size)
	player_target.x = clamp(player_target.x, 0, game_area.size.x)
	player_target.y = clamp(player_target.y, 0, game_area.size.y)
	
	# Just tween to the new target (no bounding needed if GameArea is big enough)
	var t: Tween = create_tween()
	t.tween_property(player_node, "position", player_target, 0.2 * steps)
	await t.finished
