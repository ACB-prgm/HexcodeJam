extends Area2D


onready var trail = $Trail
onready var shatterSound = $ShatterSound
onready var shootSound = $ShootSound

var moving = true
var dead = false
var parried = false
var velocity = Vector2(0, 2000)

func _ready():
	randomize()
	shatterSound.pitch_scale += rand_range(0.05, 0.2)
	shootSound.pitch_scale = 1.3 + rand_range(0, 0.1)
	shootSound.play()

func _physics_process(delta):
	if moving:
		global_position += velocity.rotated(rotation) * delta


func _on_Enemy_Projectile_area_entered(area):
	var coll_layer = area.collision_layer
	
	if coll_layer == 512:
		if !parried:
			parried = true
			$Sprite.flip_v = true
			velocity *= -1
			var shape = CircleShape2D.new()
			shape.set_radius(25)
			$CollisionShape2D.set_shape(shape)
			
	elif parried and coll_layer in [32, 128]:
		die()
	elif coll_layer in [1, 64]:
		die()


func _on_Enemy_Projectile_body_entered(body):
	if body.collision_layer in [2, 8]:
		die()


func die():
	if !dead:
		dead = true
		
		trail.emitting = false
		trail.global_position = global_position
		call_deferred("remove_child", trail)
		call_deferred("remove_child", shatterSound)
		get_parent().call_deferred("add_child", trail)
		get_parent().call_deferred("add_child", shatterSound)
		trail.reparented()
		shatterSound.play()
		
		queue_free()
