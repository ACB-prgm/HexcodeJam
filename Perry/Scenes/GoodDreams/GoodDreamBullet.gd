extends Area2D


onready var deathTween = $DeathTween
onready var trail = $Trail

var moving:bool = true
var dead = false


func _physics_process(delta):
	if moving:
		global_position -= Vector2(2500, 0).rotated(rotation) * delta
	

func _on_GoodDreamBullet_area_entered(_area):
	die()


func _on_GoodDreamBullet_body_entered(body):
	if body.collision_layer in [2, 4, 8]:
		die()


func die():
	if !dead:
		dead = true
		$CollisionShape2D.set_deferred("disabled", true)
		moving = false
		
		$AnimatedSprite.modulate *= 1.5
		deathTween.interpolate_property(self, "scale", Vector2(1.5,1.5), Vector2(0.1, 0.1),
		0.1, Tween.TRANS_ELASTIC, Tween.EASE_IN)
		deathTween.start()
		
		trail.emitting = false
		trail.global_position = global_position
		call_deferred("remove_child", trail)
		get_parent().call_deferred("add_child", trail)
		trail.reparented()

func _on_DeathTween_tween_all_completed():
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	die()
