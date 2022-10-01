extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var _move_speed = 190
export var _jump_force = 280
export var _gravity = 800

export (float, 0, 1.0) var friction = 0.25
export (float, 0, 1.0) var accel = 0.15

var _can_jump = true
var _jumped = false
var _jumping = false
var _grounded = false

var _direction = Vector2.ZERO
var _velocity  = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	get_input()
	
	var last_pos = position
	_velocity.y = clamp(_velocity.y + _gravity * delta, -400, 400)
	_velocity = move_and_slide(_velocity, Vector2.UP)
	
	if abs(_velocity.y) > 1000: 
		print("Pos %s | last %s " % [position, last_pos])
	
	if get_slide_count() == 0:
#			print("Not paused (velo y %s | pos %s)" % [_velocity.y, global_position])
		_grounded = false
		
		if _velocity.y > 0 and _jumping:
			_jumped = false
			_jumping = false
		
		if $Coyote.is_stopped():
			print("Starting")
			$Coyote.start()
	elif is_on_floor():
		if !_grounded:
			print("Landed")
		_grounded = true
		_can_jump = true
		_velocity.y = 0
	
	
	if _jumping:
		if (_can_jump and _grounded) or _can_jump:
			_jumped = true
			_can_jump = false
			_velocity.y -= _jump_force


func get_input():
	
	_direction.x = 0
	if Input.is_action_pressed("move_left"):
		_direction.x -= _move_speed
	if Input.is_action_pressed("move_right"):
		_direction.x += _move_speed
	if Input.is_action_just_pressed("jump"):
		_jumping = true
	
	if _direction.x != 0:
		_velocity.x = lerp(_velocity.x, _direction.x, accel)
	else:
		_velocity.x = lerp(_velocity.x, 0, friction)
		if _velocity.x < 2.0:
			_velocity.x = 0
	
	if _velocity.x == 0 and _velocity.y == 0 and !_jumping:
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
	_grounded = false

func _off_screen():
	get_tree().current_scene.game_over()
