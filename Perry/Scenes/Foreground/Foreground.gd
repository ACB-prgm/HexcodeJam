extends CanvasLayer


export var visible_in_game = true

onready var shadows = $Control/UpperShadows


func _ready():
	if !visible_in_game:
		self.queue_free()


func _on_hide_shadows(hide):
	if hide:
		shadows.hide()
	else:
		shadows.show()
