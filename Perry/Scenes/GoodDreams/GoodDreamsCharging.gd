extends Node2D


onready var ring1 = $Ring1
onready var ring2 = $Ring2
onready var ring3 = $Ring3
onready var ring4 = $Ring4
onready var ring5 = $Ring5
onready var ring6 = $Ring6
onready var rings = [ring1, ring2, ring3, ring4, ring5, ring6]
onready var shoot_rings = rings.duplicate(true)
onready var pointer = $Pointer
onready var shootTimer = $ShootTimer
onready var shootTween = $ShootTween
onready var deathTween = $DeathTween

var dreamBullet = preload("res://Scenes/GoodDreams/GoodDreamBullet.tscn")
var rot = 0.1
var input_vector:Vector2 = Vector2.ZERO
var last_input_vector = Vector2.UP
var can_shoot:bool = true

signal good_dream_ended


func _physics_process(_delta):
	pointing()
	shooting()
	
	for ring in rings:
		rot *= -1
		ring.rotate(rot)


func pointing():
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		pointer.position = lerp(pointer.position, input_vector * 200, .05)
		last_input_vector = input_vector
		pointer.look_at(self.global_position)
	else:
		pointer.position = lerp(pointer.position, last_input_vector * 200, .1)
		pointer.look_at(self.global_position)




func shooting():
	if Input.is_action_pressed("ui_attack") and can_shoot:
		$ShootSound.play()
		can_shoot = false
		shootTimer.start()
		
		shootTween.interpolate_property(self, "modulate", Color(1.56,1.44,1.56,1.2), Color(1.3, 1.2, 1.3, 1), 
		0.3, Tween.TRANS_BACK, Tween.EASE_OUT)
		shootTween.interpolate_property(pointer, "scale", 
		Vector2(1.5, 1.5), Vector2(1,1), 
		0.3, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		shootTween.start()
		
		var bullet = dreamBullet.instance()
		bullet.global_position = pointer.global_position
		bullet.rotation = pointer.rotation
		get_parent().add_child(bullet)


func _on_ShootTimer_timeout():
	can_shoot = true


func die():
	shootTimer.stop()
	can_shoot = false
	scale = Vector2(1.25,1.25)
	modulate *= 2
	
	deathTween.interpolate_property(self, "scale", scale, Vector2(.25, .25), 
	0.15, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT, 0.1)
	deathTween.start()


func _on_DeathTween_tween_all_completed():
	emit_signal("good_dream_ended")
	queue_free()


func _on_DurationTimer_timeout():
	die()
