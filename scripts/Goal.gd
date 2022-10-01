extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_body_entered(body):
	if !get_tree().current_scene.level_completed:
		get_tree().current_scene.level_complete()
