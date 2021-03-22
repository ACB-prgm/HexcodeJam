tool
extends Label


onready var hoverSound = $HoverSound
onready var clickSound = $ClickSound

signal TextButton_Pressed


func _ready():
	set_process(true)


func _process(_delta):
	if Engine.editor_hint:
		rect_pivot_offset = rect_size/2.0

	if not Engine.editor_hint:
		set_process(false)


func _on_Button_pressed():
	clickSound.play()
	if not Engine.editor_hint:
		emit_signal("TextButton_Pressed")


func _on_Button_mouse_entered():
	hoverSound.play()
	if not Engine.editor_hint:
		set_modulate(Color(1.1, 1.1, 1.1, 1))


func _on_Button_mouse_exited():
	if not Engine.editor_hint:
		set_modulate(Color(1, 1, 1, 1))
