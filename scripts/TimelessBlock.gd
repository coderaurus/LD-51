extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _falling = false
var player
var velocity = Vector2.ZERO


export var _gravity = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if _falling:
		velocity = Vector2(0, clamp(velocity.y + _gravity * delta, -400, 400))
		velocity = move_and_slide(velocity, Vector2.UP)
		if player != null:
			var distance = player.global_position.distance_to(global_position)
			print(distance)
			if distance <= 4:
#				player._velocity += velocity * 0.1
				player._grounded = false
			else: 
				player._on_timeless_block = false
				player = null
#		force_update_transform()

func _on_body_entered(body):
	if body.is_in_group("player") and !_falling:
		player = body
		player._on_timeless_block = true
#		add_child(player)
		_start_fall()
		print("Player entered the block %s" % self)

func _on_body_exited(body):
	if body.is_in_group("player"):
#		remove_child(player)
		player._on_timeless_block = false
		player = null
		print("Player left the block %s" % self)
		


func _start_fall():
	var origin = global_position
	var tween = create_tween().set_loops(6)
	tween.tween_property(self, "global_position", origin + Vector2.RIGHT * 2, 0.1)
	tween.tween_property(self, "global_position", origin + Vector2.LEFT * 2, 0.1)
	tween.tween_callback(self, "_fall")
	
func _fall():
	_falling = true
	set_collision_layer_bit(2, false)
#	if player != null:
#		player._jumping = true
##
#	var origin = global_position
#	var tween = create_tween()
#	tween.tween_property(self, "global_position", origin + Vector2.DOWN * 320, 2.0).set_trans(Tween.TRANS_EXPO)
#	tween.tween_callback(self, "_cleanup")
#
#func _cleanup():
#	call_deferred("queue_free")


func _on_despawn():
	queue_free()
