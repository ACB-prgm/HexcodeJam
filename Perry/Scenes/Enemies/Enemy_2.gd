extends KinematicBody2D


const LEFT_BORDER = 0
const RIGHT_BORDER = 1080
const PAUSE_FRAME_LIMIT = 5

export var Max_vel = 300
export var Acceleration = 30
export var health = 1
export var shake_amt = 200

onready var spawn_pos = $AnimatedSkeleton/SpawnPosition
onready var animSkeleton = $AnimatedSkeleton
onready var animPlayer = $AnimatedSkeleton/AnimationPlayer
onready var attackTimer = $AttackTimer
onready var hitSound = $HitSound
onready var deathSound = $DeathSound
onready var anim_PlaybackSpeed = animPlayer.playback_speed

var projectile_spawner = preload("res://Scenes/Enemies/Enemy_Projectile_spawner.tscn")
var death_TSCN = preload("res://Scenes/Enemies/EnemyDeath/EnemyDeath.tscn")
var velocity = Vector2.ZERO
var direction = Vector2.RIGHT
var traveling_to_screen = true
var dead = false
var frame = 0
var move_frame_limit = 100

enum {
	PAUSED,
	MOVE,
	ATTACK
}
var last_state = MOVE
var state = MOVE

signal enemy_died


func _ready():
	randomize()
	move_frame_limit = int(rand_range(50, 250))
	attackTimer.wait_time = rand_range(3, 6)
	attackTimer.start()


func _physics_process(_delta):
	if health <= 0:
		die()
	
	match state:
		PAUSED:
			pause()
		MOVE:
			movement()
		ATTACK:
			attacking()


# MOVEMENT FUNCTIONS ———————————————————————————————————————————————————————————
func movement():
	animPlayer.play("walk")
	
	if global_position.x < LEFT_BORDER:
		direction = Vector2.RIGHT
		traveling_to_screen = true
		attackTimer.paused = true
		frame -= 1
	elif global_position.x > RIGHT_BORDER:
		direction = Vector2.LEFT
		traveling_to_screen = true
		attackTimer.paused = true
		frame -= 1
	else:
		attackTimer.paused = false
		traveling_to_screen = false
		frame += 1
		if frame >= move_frame_limit:
			frame = 0
			move_frame_limit = int(rand_range(50, 250))
			direction *= -1
	
	velocity += Acceleration * direction
	velocity = velocity.clamped(Max_vel)
# warning-ignore:return_value_discarded
	move_and_slide(velocity)
	
	if direction == Vector2.RIGHT:
		animSkeleton.scale.x = -1
	else:
		animSkeleton.scale.x = 1


# ATTACK FUNCTIONS —————————————————————————————————————————————————————————————
func _on_AttackTimer_timeout():
	if state != PAUSED:
		if !traveling_to_screen:
			if global_position.x > LEFT_BORDER + 100 and global_position.x < RIGHT_BORDER - 100:
				state = ATTACK
				animPlayer.play("stomp")
			else:
				attackTimer.set_wait_time(0.5)
				attackTimer.start()
		else:
			attackTimer.set_wait_time(rand_range(3, 6))
			attackTimer.start()

func _on_stomp(finished:bool):
	if !finished:
		var spawner = projectile_spawner.instance()
		spawner.global_position = spawn_pos.global_position
		get_parent().add_child(spawner)
	else:
		attackTimer.set_wait_time(rand_range(3, 6))
		attackTimer.start()
		state = MOVE

func flip_direction():
	animSkeleton.scale.x *= -1

func attacking():
	pass


# DEATH FUNCTIONS ——————————————————————————————————————————————————————————————
func _on_Hitbox_area_entered(area):
	_Camera.shake(30, .4, 120)
	frame = 0
	if state != PAUSED:
		last_state = state
	else:
		last_state = MOVE
	
	if area.collision_layer == 128:
		if area.parried:
			state = PAUSED
			health -= 1
	else:
		state = PAUSED
		health -= 1
	
	hitSound.pitch_scale = 1 + rand_range(0.05, 0.1)
	hitSound.play()


func die():
	if !dead:
		dead = true
		
		var death_ins = death_TSCN.instance()
		death_ins.global_position = global_position
		get_parent().add_child(death_ins)
		
		call_deferred("remove_child", deathSound)
		get_parent().call_deferred("add_child", deathSound)
		deathSound.play()
		
		_Camera.shake(shake_amt, 0.4, 200)
		emit_signal("enemy_died")
		queue_free()


func pause():
	animPlayer.playback_speed = 0
	if frame >= PAUSE_FRAME_LIMIT:
		animPlayer.playback_speed = anim_PlaybackSpeed
		frame = 0
		state = last_state
	frame += 1
