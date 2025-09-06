extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const TILE_SIZE = 32

var blockly_speed = 130.0  # pixels per second when moving between tiles
var blockly_tile_x: int = 0
var blockly_anchored: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Blockly movement state
var blockly_target: Vector2 = Vector2.ZERO
var blockly_active: bool = false

signal blockly_step_done

# === Blockly API ===
func blockly_move(direction: int, steps: int) -> void:
	if not blockly_anchored:
		# Compute horizontal tile index from center
		blockly_tile_x = int(position.x / TILE_SIZE)
		blockly_anchored = true

	# Advance tile index
	blockly_tile_x += direction * steps

	# Compute exact target pixel (tile-centered)
	blockly_target = Vector2(blockly_tile_x * TILE_SIZE + TILE_SIZE / 2, position.y)
	blockly_active = true


func blockly_jump() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

# === Physics process ===
func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Keyboard jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Determine control
	if blockly_active:
		_handle_blockly_movement()
	else:
		_handle_input_movement()

	move_and_slide()
	_update_animation()

# === Player input ===
func _handle_input_movement() -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

# === Blockly movement ===
func _handle_blockly_movement() -> void:
	var dx = blockly_target.x - position.x

	if abs(dx) <= 1.0:
		position.x = blockly_target.x
		velocity.x = 0.0
		blockly_active = false
		emit_signal("blockly_step_done")
		return

	velocity.x = sign(dx) * blockly_speed

# === Animation ===
func _update_animation() -> void:
	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true

	if not is_on_floor():
		animated_sprite.play("jump")
	elif abs(velocity.x) > 5:
		animated_sprite.play("run")
	else:
		animated_sprite.play("Idle")
