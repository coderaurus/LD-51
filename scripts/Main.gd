extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var level_started = false
var level_completed = false
var level = 0
var current_level : Node2D

var landing_particle = preload("res://scenes/particles/LandingParticle.tscn")

export var level_list := []

# Called when the node enters the scene tree for the first time.
func _ready():
	level = 0
	_load_level()
	$UI/Timer.text = "%.4f" % 10.0
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !get_tree().paused:
		$UI/Timer.text = "%.4f" % $Countdown.time_left
		
	if Input.is_action_just_pressed("restart"):
		_load_level()


func time_up():
	$Countdown.start(clamp($Countdown.time_left + 1.0, 0, 10.0))


func pause_flow(pause = true):
#	if get_tree().paused != pause:
#		print("Pausing flow %s" % pause)
	if !pause and !level_started:
		_start_level()
	
	get_tree().paused = pause

func _start_level():
	level_started = true
	$Countdown.start()

func level_complete():
	level_completed = true
#	get_tree().reload_current_scene()
	
	if level+1 < level_list.size():
		level += 1
		_load_level()
	else:
		print("Game done!")

func _load_level():
	get_tree().paused = true
	level_started = false
	level_completed = false
	
	if level > 0:
		call_deferred("remove_child", current_level)
		var last_level = current_level
		current_level = null
		last_level.call_deferred("queue_free")
	
	var next_level = (level_list[level] as PackedScene).instance()
	
	call_deferred("add_child_below_node", $Countdown, next_level)
	current_level = next_level
	
	$Player.position = current_level.get_node("Objects/PlayerSpawn").position
	$Player.reset()
	$Countdown.start(10.0)
	$Countdown.stop()

func play_landing(pos):
	print("landing")
	var p = landing_particle.instance()
	add_child(p)
	p.owner = self
	p.global_position = pos
	p.emitting = true


func game_over():
	print("GAME OVER")
	_load_level()


func _on_Countdown_timeout():
	_load_level()
	print("Countdown timeout at %s" % $Countdown.time_left)
