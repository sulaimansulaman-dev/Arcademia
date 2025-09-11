extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const TILE_SIZE = 16   # <-- updated for your tiles

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# === Blockly movement state ===
var blockly_target: Vector2 = Vector2.ZERO
var blockly_active: bool = false

signal blockly_step_done

# === Blockly API ===
func blockly_move(direction: int, steps: int) -> void:
	# Snap current X to grid center
	var current_tile_x = floor(position.x / TILE_SIZE)

	# Target tile index
	var target_tile_x = current_tile_x + (direction * steps)

	# Exact pixel center of target tile
	blockly_target = Vector2(target_tile_x * TILE_SIZE + TILE_SIZE / 2, position.y)
	blockly_active = true

func blockly_jump() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		
func blockly_move_and_jump(steps: int) -> void:
	# Snap current X to grid
	var current_tile_x = floor(position.x / TILE_SIZE)

	# Target tile index to the right
	var target_tile_x = current_tile_x + steps

	# Target world position (same height, will jump into the air)
	blockly_target = Vector2(target_tile_x * TILE_SIZE + TILE_SIZE / 2, position.y)
	blockly_active = true

	# Trigger jump at the same time
	if is_on_floor():
		velocity.y = JUMP_VELOCITY


# === Physics process ===
func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle Blockly movement
	if blockly_active:
		_handle_blockly_movement()
	else:
		velocity.x = 0

	move_and_slide()
	_update_animation()

# === Blockly movement handler ===
func _handle_blockly_movement() -> void:
	var dx = blockly_target.x - position.x

	if abs(dx) <= 1.0: # close enough
		position.x = blockly_target.x
		velocity.x = 0.0
		blockly_active = false
		emit_signal("blockly_step_done")
	else:
		velocity.x = sign(dx) * SPEED

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
