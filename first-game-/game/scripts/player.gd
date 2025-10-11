extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -400
const TILE_SIZE = (16)* 1.4   # <-- updated for your tiles

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


# === Blockly movement state ===
var blockly_target: Vector2 = Vector2.ZERO
var blockly_active: bool = false

signal blockly_step_done

var step_cooldown: float = 0.0

func _play_step_sound() -> void:
	if AudioManager.sfx_steps.is_empty():
		return

	var step_sound: AudioStream = AudioManager.sfx_steps.pick_random()  # explicitly typed
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = step_sound
	player.volume_db = -18.0  # quieter footsteps
	player.pitch_scale = randf_range(0.95, 1.05)  # slight random pitch variation
	add_child(player)
	player.play()

	# Timer to safely free the player after the sound finishes
	var timer: Timer = Timer.new()
	timer.wait_time = step_sound.get_length()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(Callable(self, "_on_step_sound_finished").bind(player, timer))
	timer.start()
	
	step_cooldown = 0.25

func _on_step_sound_finished(player: AudioStreamPlayer, timer: Timer) -> void:
	if is_instance_valid(player):
		player.queue_free()
	if is_instance_valid(timer):
		timer.queue_free()

	

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
		AudioManager.play_sound(AudioManager.sfx_jump)
		
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
		AudioManager.play_sound(AudioManager.sfx_jump)

var was_on_floor: bool = false

# === Physics process ===
func _physics_process(delta: float) -> void:
	var on_floor_now = is_on_floor()
	
	# Landing sound
	if on_floor_now and not was_on_floor:
		AudioManager.play_sound(AudioManager.sfx_landing)
	
	# Apply gravity
	if not on_floor_now:
		velocity += get_gravity() * delta

	# Handle Blockly movement
	if blockly_active:
		_handle_blockly_movement()
	else:
		velocity.x = 0
		
	step_cooldown = max(0.0, step_cooldown - delta)
	
	move_and_slide()
	_update_animation()

	# Update the state for next frame
	was_on_floor = on_floor_now


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
	
	if animated_sprite.animation == "run" and abs(velocity.x) > 5 and is_on_floor():
		_play_step_sound()
			

func is_ground_ahead() -> bool:
	if $GapRay.is_colliding():
		print("Colliding")
		return true
	print("Not Colliding")
	return false
func is_wall_ahead() -> bool:
	if $WallRay.is_colliding():
		print("Wall ahead: true (colliding with ", $WallRay.get_collider(), ")")
		return true
	print("Wall ahead: false")
	return false
