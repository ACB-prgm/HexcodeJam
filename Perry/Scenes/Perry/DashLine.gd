extends Line2D


onready var midLine = $MiddleLine2D
onready var tween = $Tween
onready var start_pos = global_position
onready var player = Globals.player

var finished = false


func _physics_process(_delta):
	points[0] = to_local(start_pos)
	midLine.points[0] = to_local(start_pos)
	
	points[1] = to_local(player.global_position)
	midLine.points[1] = to_local(player.global_position)


func _on_attack_finished():
	if !finished:
		finished = true
		
		set_physics_process(false)
		tween.interpolate_property(self, "modulate", modulate, Color(1,1,1,0), 
		.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
