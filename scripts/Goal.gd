extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.play("Idle")
	pass # Replace with function body.


func _on_body_entered(body):
	var game_state_ok = !get_tree().current_scene.level_completed and get_tree().current_scene.level_started
	var is_player = body.is_in_group("player")
	
	if game_state_ok and is_player:
		print("Goal %s reached!" % self)
		get_tree().current_scene.level_complete()
		queue_free()
