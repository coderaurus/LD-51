extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _move_speed = 350
var _jump_force = 500
var _speed_limit = 100

var _current_direction = Vector2.ZERO
var _direction = Vector2.ZERO

var _can_jump = true
var _jumped = false
var _falling = false
var _mid_air = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("jump"):
		_jump()
	
	if Input.is_action_pressed("move_left"):
		_direction = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		_direction = Vector2.RIGHT
	else:
		_direction = Vector2.ZERO

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(state):
	_update_movement()
	_update_states()
	pass


func _update_states():
	if $Feet.is_colliding():
#		print("Feet on the ground")
		_mid_air = false
		_falling = false
		_can_jump = true
		_jumped = false
	else:
		if _is_falling():
			_falling = true
		if $Coyote.is_stopped():
			$Coyote.start()
	

func _update_movement():
	
	if _direction != _current_direction:
		_current_direction = _direction
#		linear_velocity = _direction * _move_speed * 0.5
	if _current_direction != Vector2.ZERO:
		if !_mid_air:
			add_force(Vector2.ZERO, _current_direction * _move_speed)
		elif $Feet.is_colliding():
			add_force(Vector2.ZERO, _current_direction * _move_speed * 0.25)
#	else:
#		linear_velocity = Vector2.ZERO

	# Not moving 
	if _direction == Vector2.ZERO and !_is_falling() and !_is_mid_air():
		linear_velocity.x = 0
		applied_force.x = applied_force.x * 0.25
	
	
	# Correct velocity
	_correct_velocity()
	
	
func _correct_velocity():
	var correction = Vector2.ZERO
	if abs(linear_velocity.x) >= _speed_limit or (_is_mid_air() and abs(linear_velocity.x) >= _speed_limit * 0.25 ):
		if _is_mid_air():
			var air_limit = _speed_limit * 0.25
			if linear_velocity.x > 0:
				correction.x = air_limit
			else:
				correction.x = -air_limit
		else:
			if linear_velocity.x > 0:
				correction.x = _speed_limit
			else:
				correction.x = -_speed_limit
	else:
		correction.x = linear_velocity.x
	
	if abs(linear_velocity.y) >= _speed_limit:
		if linear_velocity.y > 0:
			correction.y = _speed_limit
		else:
			correction.y = -_speed_limit
	else:
		correction.y = linear_velocity.y
		
	if correction != Vector2.ZERO:
#		print("Correcting")
		linear_velocity = correction

func _jump():
	if !_jumped and !_is_mid_air() and _can_jump:
		print("Jumped")
		_jumped = true
		apply_impulse(Vector2.ZERO, Vector2.UP * _jump_force)


func _is_mid_air():
	if get_colliding_bodies().size() == 0:
		_mid_air = true
	else:
		_mid_air = false
	return _mid_air


func _is_falling():
	if !$Feet.is_colliding() and _is_mid_air() and linear_velocity.y > 0:
		return true
	
	return false

func _on_Coyote_timeout():
	_can_jump = false


func _on_Debug_timeout():
	if linear_velocity != Vector2.ZERO:
		print("Linear: %s | Angular: %s " % [linear_velocity, angular_velocity])
		print("Applied: %s " % applied_force)
	if $Feet.is_colliding():
		print("Feet on the ground")
		print("Applied: %s " % applied_force)
	
