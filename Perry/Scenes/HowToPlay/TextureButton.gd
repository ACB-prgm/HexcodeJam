tool
extends TextureButton


onready var hoverSound = $HoverSound
onready var clickSound = $ClickSound

export var right: bool = true setget set_direction


signal page_button_pressed(right)


func set_direction(right_dir):
	if right_dir:
		rect_scale.x = 1
		right = true
	else:
		rect_scale.x = -1
		right = false


func _on_TextureButton_pressed():
	clickSound.play()
	emit_signal("page_button_pressed", right)


func _on_TextureButton_mouse_entered():
	hoverSound.play()
	set_modulate(Color(1.1, 1.1, 1.1, 1))


func _on_TextureButton_mouse_exited():
	set_modulate(Color(1,1,1,1))
