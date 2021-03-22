extends CanvasLayer


onready var tween = $Tween
onready var static_sprite = $Control/Static
onready var recalibrating_texture = $Control/Recalibrating

var tree = null
var scene = null

signal hide_shadows(yes_no)


func _ready():
# warning-ignore:return_value_discarded
	connect("hide_shadows", Foreground, "_on_hide_shadows")


func _in(hideshadows:bool = false):
	emit_signal("hide_shadows", hideshadows)
	
	recalibrating_texture.show()
	yield(get_tree().create_timer(1), "timeout")
	static_sprite.set_modulate(Color(1,1,1,1))
	recalibrating_texture.hide()
	
	tween.interpolate_property(static_sprite, "modulate", 
	Color(1,1,1,1), Color(1,1,1,0), 0.5, Tween.TRANS_QUAD, Tween.EASE_IN, 0.5)
	tween.start()
	_Camera.shake(150, 1, 150)


func _out(new_tree=null, new_scene=null):
	tree = new_tree
	scene = new_scene
	
	tween.interpolate_property(static_sprite, "modulate", 
	Color(1,1,1,0), Color(1,1,1,1), 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	_Camera.shake(200, 1, 200)


func _on_Tween_tween_all_completed():
	if tree and scene:
		tree.change_scene(scene)
		tree = null
		scene = null
