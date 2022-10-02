extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var _move_speed = 180
export var _jump_force = 260
export var _gravity = 800

export (float, 0, 1.0) var friction = 0.25
export (float, 0, 1.0) var accel = 0.15

var _can_jump = true
var _jumped = false
var _jumping = false
var _grounded = false
var _on_timeless_block = false

var _direction = Vector2.ZERO
var _velocity  = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	_play_animation("Fall")
	pass # Replace with function body.


func _physics_process(delta):
	if !get_parent().level_started:
		_play_animation("Fall")
	
	get_input()
	
	if !get_tree().paused and get_parent().level_started and !get_parent().level_completed:
		var last_pos = position
		_add_velocity(delta)
#		force_update_transform()
		# For debugging kinematic + kinematic collision between player and falling block
	#	if abs(_velocity.y) > 1000: 
	#		print("Pos %s | last %s " % [position, last_pos])
		_handle_states()
	

func _handle_states():
#	print("Sliding %s" % get_slide_count())
	if get_slide_count() == 0 or (get_slide_count() > 0 and is_on_wall() and !is_on_floor()):
		
#			print("Not paused (velo y %s | pos %s)" % [_velocity.y, global_position])
		_grounded = false
		_play_animation("Fall")
		
		if _velocity.y > 0 and _jumping:
			_jumped = false
			_jumping = false
		
		if $Coyote.is_stopped():
#			print("Starting")
			$Coyote.start()
	elif is_on_floor():
#		print("Flooring")
		if !_grounded:
			$Coyote.stop()
			_play_animation("Land")
			SoundManager.sound("land")
			get_parent().play_landing(global_position + Vector2.DOWN * 7)
#			print("Landed %s" % _velocity)
		_grounded = true
		_can_jump = true
		_velocity.y = 0
	
	if _jumping:
		if (_can_jump and _grounded) or _can_jump:
			var jump_mod = 1.0
			if _on_timeless_block:
				jump_mod = 1.0
				_on_timeless_block = false
				
			_jumped = true
			_can_jump = false
			_velocity.y -= _jump_force * jump_mod
			
			_play_animation("Jump")
			SoundManager.sound("jump")


func _add_velocity(delta):
	_velocity.y = clamp(_velocity.y + _gravity * delta, -400, 400)
	_velocity = move_and_slide(_velocity, Vector2.UP)


func get_input():
	
	_direction.x = 0
	if Input.is_action_pressed("move_left"):
		_direction.x -= _move_speed
		$Sprite.flip_h = true
	if Input.is_action_pressed("move_right"):
		_direction.x += _move_speed
		$Sprite.flip_h = false
	if Input.is_action_just_pressed("jump") and _can_jump:
		_jumping = true
	
	if _direction.x != 0:
		_velocity.x = lerp(_velocity.x, _direction.x, accel)
		if _grounded and !_jumping:
			_play_animation("Run")
	else:
		_velocity.x = lerp(_velocity.x, 0, friction)
		if _velocity.x < 2.0:
			_velocity.x = 0
			_play_animation("Idle", "Land")
	
	if _velocity.x == 0 and _velocity.y == 0 and !_jumping and !_on_timeless_block:
#		print("Paaause")
		get_parent().pause_flow()
	else:
#		print("No Paaause %s " % _velocity.x)
		get_parent().pause_flow(false)


func _on_Coyote_timeout():
	if !_grounded:
		_can_jump = false
		print("Coyote out")

func _on_Debug_timeout():
#	if linear_velocity != Vector2.ZERO:
#		print("Linear: %s | Angular: %s " % [linear_velocity, angular_velocity])
#		print("Applied: %s " % applied_force)
#	if $Feet.is_colliding():
#		print("Feet on the ground")
#		print("Applied: %s " % applied_force)
	pass

func reset():
	_direction = Vector2.ZERO
	_velocity  = Vector2.ZERO
	
	_can_jump = true
	_jumping = false
	_jumped = false
	_on_timeless_block = false
	_grounded = false
	
	$Sprite.flip_h = false

func _off_screen():
	if global_position.y > 0:
		get_tree().current_scene.game_over()
	

func _play_animation(anim_name, ignore_anim = ""):
	if ignore_anim != "" and $Player.current_animation == ignore_anim:
		return
	
	if $Player.has_animation(anim_name):
		$Player.advance(0)
		$Player.play(anim_name)
