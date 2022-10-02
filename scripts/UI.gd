extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var menu_visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	_init_menu()
	
	pass # Replace with function body.


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_menu()


func _init_menu():
	$Menu/Contents/Sound/HSlider.max_value = SoundManager.MAX_DB
	$Menu/Contents/Sound/HSlider.min_value = SoundManager.MUTE_DB
	
	$Menu/Contents/Music/HSlider.max_value = MusicManager.MAX_DB
	$Menu/Contents/Music/HSlider.min_value = MusicManager.MUTE_DB


func _toggle_sound():
	var slider = $Menu/Contents/Sound/HSlider
	if slider.value == SoundManager.stored_db or (slider.value <= SoundManager.MAX_DB and slider.value > SoundManager.MUTE_DB):
		SoundManager.stored_db = slider.value
		slider.value = SoundManager.MUTE_DB
		$Menu/Contents/Sound/Button.text = "No Snd"
	else:
		slider.value = SoundManager.stored_db
		$Menu/Contents/Sound/Button.text = "Sound"

func _toggle_music():
	var slider = $Menu/Contents/Music/HSlider
	if slider.value == MusicManager.stored_db or (slider.value <= MusicManager.MAX_DB and slider.value > MusicManager.MUTE_DB):
		MusicManager.stored_db = slider.value
		slider.value = MusicManager.MUTE_DB
		$Menu/Contents/Music/Button.text = "No Msc"
	else:
		slider.value = MusicManager.stored_db
		$Menu/Contents/Music/Button.text = "Music"
		



func _toggle_menu():
	if menu_visible:
		hide_menu()
	else:
		show_menu()

func hide_menu():
	var tween = create_tween().set_parallel()
	tween.tween_property($Menu/Contents, "modulate", Color.transparent, 0.5)
	tween.tween_property($Menu/Header, "rect_position", Vector2(2, 50), 0.5).set_delay(0.2)
	tween.chain().tween_property($Menu/Fade, "modulate", Color.transparent, 0.5)
	tween.chain().tween_property(self, "menu_visible", false, 0)
	

func show_menu():
	var tween = create_tween().set_parallel()
	tween.tween_property($Menu/Fade, "modulate", Color.white, 0.5)
	tween.chain().tween_property($Menu/Header, "rect_position", Vector2(2, 4), 0.5)
	tween.tween_property($Menu/Contents, "modulate", Color.white, 0.5).set_delay(0.2)
	tween.chain().tween_property(self, "menu_visible", true, 0)


func show_transition(win = false):
	var tween = create_tween()
	if !win:
		tween.tween_property($TransitionFade, "visible", true, 0)
		tween.tween_property($TransitionFade, "modulate", Color.white, 0.4)
	else:
		tween.tween_property($VictoryFade, "visible", true, 0)
		tween.tween_property($VictoryFade, "modulate", Color.white, 0.4)

func hide_transition(win = false):
	
	print("Hide transition win = %s" % win)
	var tween = create_tween()
	if !win:
		tween.tween_property($TransitionFade, "modulate", Color.transparent, 0.8)
		tween.tween_property($TransitionFade, "visible", false, 0)
	else:
		tween.tween_property($VictoryFade, "modulate", Color.transparent, 0.8)
		tween.tween_property($VictoryFade, "visible", false, 0)
		

func show_victory():
	var p1 = get_parent().get_node("Dust")
	var p2 = get_parent().get_node("BlackParticles")
	
	if get_parent()._particles_on:
		p1.emitting = false
		p2.emitting = false
		
	$Victory.visible = true
	var tween = create_tween()
	tween.tween_property($Victory/TextureRect, "modulate", Color.white, 0.75)
	tween.tween_property($Victory/Text/Label, "modulate", Color.white, 0.5)
	tween.tween_property($Victory/Text/Label2, "modulate", Color.white, 0.5).set_delay(0.5)
	tween.tween_property($Victory/Text/Label3, "modulate", Color.white, 0.5).set_delay(1.0)
	tween.tween_property($Victory/Restart, "modulate", Color.white, 0.75)
	

func _on_start_pressed():
	hide_menu()
	SoundManager.sound("click")


func restart():
	print("Restart tweeen")
	var tween = create_tween().set_parallel()
	tween.tween_property($VictoryFade, "modulate", Color.transparent, 0)
	tween.tween_property($VictoryFade, "visible", false, 0)
	
	tween.tween_property($TransitionFade, "modulate", Color.white, 0)
	tween.tween_property($TransitionFade, "visible", true, 0)
	
	tween.tween_property($Victory/Text/Label, "modulate", Color.transparent, 0.5)
	tween.tween_property($Victory/Text/Label2, "modulate", Color.transparent, 0.5)
	tween.tween_property($Victory/Text/Label3, "modulate", Color.transparent, 0.5)
	tween.tween_property($Victory/Restart, "modulate", Color.transparent, 0.5)
	tween.chain().tween_property($Victory/TextureRect, "modulate", Color.transparent, 0.75)
	tween.chain().tween_callback(get_parent(), "_load_level")
	
	
	var p1 = get_parent().get_node("Dust")
	var p2 = get_parent().get_node("BlackParticles")
	
	if get_parent()._particles_on:
		p1.emitting = true
		p2.emitting = true
		
	


func _on_sound_changed(value):
	SoundManager._on_range_changed(value)
	pass # Replace with function body.


func _on_music_changed(value):
	MusicManager._on_range_change(value)
	pass # Replace with function body.


func _on_music_toggle_pressed():
	_toggle_music()
	SoundManager.sound("click")


func _on_sound_toggle_pressed():
	_toggle_sound()
	SoundManager.sound("click")


func _on_Restart_level_pressed():
	get_parent()._load_level()
	SoundManager.sound("click")
