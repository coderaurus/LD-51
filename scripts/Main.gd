extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var level_started = false
var level_completed = false
var level
var current_level : Node2D
var _game_complete = false
var _particles_on = true

var landing_particle = preload("res://scenes/particles/LandingParticle.tscn")

export var level_list := []

# Called when the node enters the scene tree for the first time.
func _ready():
	level = 0
#	print("Ready...")
	_load_level()
#	level = 4
	
	MusicManager.song("main")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !get_tree().paused:
		$UI/Timer.text = "%.4f" % $Countdown.time_left
		
	if !_game_complete and Input.is_action_just_pressed("restart"):
		print("Restart pressed")
		_load_level()


func time_up():
	$Countdown.start(clamp($Countdown.time_left + 1.0, 0, 10.0))
	SoundManager.sound("pickup")


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
		SoundManager.sound("level_clear")
		level += 1
		_load_level()
	else:
		_game_completed()
		print("Game done!")

func _load_level():
	get_tree().paused = true
	var next_level = (level_list[level] as PackedScene).instance()
	
	var win_fade = level_completed
	$UI.show_transition(win_fade)
	yield(get_tree().create_timer(0.5), "timeout")
	
	
	level_started = false
	level_completed = false
	
	if current_level != null:
		var last_level = current_level
		call_deferred("remove_child", current_level)
		last_level.visible = false
		current_level = null
		last_level.call_deferred("queue_free")
		$Player.global_position = Vector2.LEFT * 500
	else:
		current_level = next_level

	
	call_deferred("add_child_below_node", $Countdown, next_level)
	current_level = next_level
	
	$Player.position = current_level.get_node("Objects/PlayerSpawn").position
	$Player.reset()
	
	$Countdown.start(10.0)
	$Countdown.stop()
	$UI/Timer.text = "%.4f" % 10.0
	
	$UI.hide_transition(win_fade)
	yield(get_tree().create_timer(0.5), "timeout")

func play_landing(pos):
	if !_particles_on:
		return
	
	var p : CPUParticles2D = landing_particle.instance()
	$Particles.add_child(p)
	p.owner = $Particles
	p.global_position = pos
	p.emitting = true
	yield(get_tree().create_timer(0.55), "timeout")
	p.queue_free()

func _game_completed():
	_game_complete = true
	MusicManager.stop()
	$UI.show_transition(true)
	yield(get_tree().create_timer(2.0), "timeout")
	$UI.show_victory()
	MusicManager.song("end")
	

func game_over():
#	print("GAME OVER")
	SoundManager.sound("death")
	_load_level()


func _on_Countdown_timeout():
#	print("Countdown timeout at %s" % $Countdown.time_left)
	if $Countdown.time_left == 0 and !level_completed or !_game_complete:
		game_over()


func restart_game():
	SoundManager.sound("click")
	get_tree().paused = true
	
	level_completed = false
	level_started = false
	_game_complete = false
	level = 0
	
	$Countdown.start(10)
	$Countdown.stop()
	
	
	$UI.restart()
	MusicManager.song("main")
	


func _on_particle_toggled():
	_particles_on = !_particles_on
	$Dust.emitting = _particles_on
	$BlackParticles.emitting = _particles_on
	if _particles_on:
		$UI/Menu/Contents/ParticleTogle.text = "Particles"
	else:
		$UI/Menu/Contents/ParticleTogle.text = "No Prtcls"
		
