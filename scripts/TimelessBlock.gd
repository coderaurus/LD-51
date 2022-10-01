extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _falling = false
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_body_entered(body):
	if body.is_in_group("player") and !_falling:
		player = body
		_falling = true
		_start_fall()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null


func _start_fall():
	var origin = global_position
	var tween = create_tween().set_loops(6)
	tween.tween_property(self, "global_position", origin + Vector2.RIGHT * 2, 0.1)
	tween.tween_property(self, "global_position", origin + Vector2.LEFT * 2, 0.1)
	tween.tween_callback(self, "_fall")
	
func _fall():
#	if player != null:
#		player._jumping = true
#
	var origin = global_position
	var tween = create_tween()
	tween.tween_property(self, "global_position", origin + Vector2.DOWN * 320, 2.0).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(self, "_cleanup")
	
func _cleanup():
	call_deferred("queue_free")
