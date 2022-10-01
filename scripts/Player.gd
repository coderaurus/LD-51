extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var _move_speed = 200
export var _jump_force = 300
export var _gravity = 800
var _can_jump = true

var _direction = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	get_input()
	
	_direction.y += _gravity * delta
	_direction = move_and_slide(_direction, Vector2.UP)
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			_direction.y -= _jump_force



func get_input():
	_direction.x = 0
	if Input.is_action_pressed("move_left"):
		_direction.x -= _move_speed
	if Input.is_action_pressed("move_right"):
		_direction.x += _move_speed

func _on_Coyote_timeout():
	_can_jump = false

func _on_Debug_timeout():
#	if linear_velocity != Vector2.ZERO:
#		print("Linear: %s | Angular: %s " % [linear_velocity, angular_velocity])
#		print("Applied: %s " % applied_force)
	if $Feet.is_colliding():
		print("Feet on the ground")
#		print("Applied: %s " % applied_force)
	
