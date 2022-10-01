extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var menu_visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_menu()


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
		


func _on_start_pressed():
	hide_menu()
