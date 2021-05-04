extends Particles2D_Plus



func _ready():
	emitting = true
	$SkullParticles2D.emitting = true


func _on_SkullParticles2D_particles_cycle_finished():
	queue_free()
