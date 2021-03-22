extends Node2D


onready var portalSound = $PortalOpenSound
onready var tween = $Tween
onready var spawner = $Spawner
onready var fauxProjectile = $FauxProjectile
onready var player = Globals.player

var PROJECTILE = preload("res://Scenes/Enemies/Enemy_Projectile.tscn")
var portal_leaving = false
var aiming = false



func _ready():
	if global_position.x < 100:
		global_position.x = 100
	if global_position.x > 975:
		global_position.x = 975
	
	randomize()
	portalSound.pitch_scale = 1 + rand_range(-0.5, 0.5)
	portalSound.play()
	
	tween.interpolate_property(spawner, "scale", Vector2.ZERO, spawner.scale, 
	0.4, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()


func _on_Tween_tween_completed(object, key):
	if object == spawner and !portal_leaving:
		portal_leaving = true
		tween.interpolate_property(fauxProjectile, "region_rect", 
		fauxProjectile.region_rect, Rect2(0, 0, 40, 100), 
		0.5, Tween.TRANS_BACK, Tween.EASE_OUT)
		tween.interpolate_property(fauxProjectile, "position", 
		fauxProjectile.position, fauxProjectile.position - Vector2(0, 50), 
		0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		tween.start()
	elif object == fauxProjectile and key == ":rotation":
		var projectile = PROJECTILE.instance()
		projectile.global_position = fauxProjectile.global_position
		projectile.rotation = fauxProjectile.rotation
		get_parent().add_child(projectile)
		self.queue_free()


func _on_Tween_tween_step(object, key, elapsed, _value):
	
	if object == fauxProjectile and key == ":position":
		if elapsed > 0.21 and elapsed < 0.23:
			tween.interpolate_property(spawner, "scale", spawner.scale, 
			Vector2.ZERO, 0.4, Tween.TRANS_QUART, Tween.EASE_IN)
			tween.start()
		if elapsed > 0.18 and !aiming:
			aiming = true
			
			var aim_position = player.global_position + Vector2((player.input_vector.x * player.velocity.x/2.0), 0)
			
			tween.interpolate_property(fauxProjectile, "rotation", 
			fauxProjectile.rotation, fauxProjectile.global_position.angle_to_point(aim_position) + 1.5708, 
			0.05, Tween.TRANS_CIRC, Tween.EASE_IN)
			tween.start()
