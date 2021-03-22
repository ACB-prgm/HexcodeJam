extends AnimatedSprite


const MOVEMENT_SPEED = 50

onready var hitTween = $HitTween
onready var deathTween = $DeathTween
onready var hitSound = $HitSound

var health = 3
var sway_amount = 0
var connected = false
var moving = true

signal good_dream_opened


func _ready():
	randomize()


func _physics_process(delta):
	if moving:
		movement(delta)
	if health <= 0:
		set_physics_process(false)
		die()


func movement(delta):
	global_position.y += MOVEMENT_SPEED * delta
	sway_amount += .025
	global_position.x += sin(sway_amount)


func _on_Hitbox_area_entered(area):
	if area.collision_layer == 256:
		hitSound.pitch_scale = 3 + rand_range(-0.1, 0.1)
		hitSound.play()
		health -= 1
		
		hitTween.interpolate_property(self, "global_position", global_position, 
		global_position + (50 * -global_position.direction_to(area.global_position)),
		0.4, Tween.TRANS_EXPO, Tween.EASE_OUT, 0.05)
		hitTween.interpolate_property(self, "modulate", Color(1.5, 1.4, 1.5, 1), modulate,
		0.4, Tween.TRANS_EXPO, Tween.EASE_OUT, 0.05)
		hitTween.start()
		
		if !connected and health <= 0:
			connected = true
# warning-ignore:return_value_discarded
			connect("good_dream_opened", area.get_parent(), "_on_good_dream_opened")

func _on_Hitbox_body_entered(body):
	if body.collision_layer == 8:
		moving = false
		
		deathTween.interpolate_property(self, "modulate", modulate, Color(1,1,1,0),
		0.2, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT, 0.05)
		deathTween.interpolate_property(self, "scale", scale, Vector2(0.25, 0.25),
		0.25, Tween.TRANS_ELASTIC, Tween.EASE_IN)
		deathTween.start()


func die():
	emit_signal("good_dream_opened")
	
	moving = false
	playing = false
	frame = 3
	
	set_modulate(Color(3, 2.8, 3, 1))
	set_scale(Vector2(2, 2))

	deathTween.interpolate_property(self, "scale", scale, Vector2(.25, .25), 
	0.15, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT, 0.1)
	deathTween.start()


func _on_DeathTween_tween_all_completed():
	queue_free()

