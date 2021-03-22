extends CanvasLayer


var frames = 0
signal particlesCached

var GodotLoadScreen = preload("res://Scenes/GodotLoadScreenFinal/GodotLogoParticles.tres")
var GoodDreams = preload("res://Scenes/GoodDreams/GoodDreams.tres")
var GoodDreamsCharging = preload("res://Scenes/GoodDreams/GoodDreamsCharging.tres")
var EnemyProjectile = preload("res://Scenes/Enemies/Enemy_Projectile.tres")

var materials = [
	GodotLoadScreen,
	GoodDreams,
	GoodDreamsCharging,
	EnemyProjectile
]


func _ready():
	for material in materials:
		var particles_instance = Particles2D.new()
		particles_instance.set_process_material(material)
		particles_instance.set_visible(false)
		particles_instance.set_one_shot(true)
		particles_instance.set_emitting(true)
		self.add_child(particles_instance)


func _physics_process(_delta):
	if frames >= 3:
		set_physics_process(false)
		emit_signal("particlesCached")
	frames += 1
