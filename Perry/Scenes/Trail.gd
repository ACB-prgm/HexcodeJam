extends Particles2D


var frame = 0


func _ready():
	set_physics_process(false)


func _physics_process(_delta):
	if frame >= 120:
		set_physics_process(false)
		self.queue_free()
	frame += 1


func reparented():
	set_physics_process(true)
