extends KinematicBody2D


const MAX_VEL_X = 100
const MAX_VEL_Y = 50
const ATTACK_SPEED = 2000
const ACCELERATION = 10
const LEFT_BORDER = 100
const RIGHT_BORDER = 975
const BOTTOM_BORDER = 1025
const HIT_FRAME_LIMIT = 10

onready var animPlayer = $AnimatedSkeleton/AnimationPlayer
onready var animSkeleton = $AnimatedSkeleton
onready var hurtbox_col = $Hurtbox/CollisionShape2D
onready var hitTween = $HitTween
onready var hitSound = $HitSound
onready var deathSound = $DeathSound
onready var player = Globals.player

var death_TSCN = preload("res://Scenes/Enemies/EnemyDeath/EnemyDeath.tscn")
var health = 5
var frame = 0
var flee_target_x = 0
var idle_frame_limit = 0
var charging = false
var cooling_down = false
var found_cool_down_pos = false
var dead = false
var cool_down_pos: Vector2 = Vector2.ZERO
var last_player_pos: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.RIGHT

enum {
	IDLE,
	MOVE,
	ATTACK,
	HIT
}
var state = MOVE
var last_state = MOVE

signal enemy_died


func _ready():
	randomize()
	
	if rand_range(0, 5) > 2.5:
		flee_target_x = 1080
	
	idle_frame_limit = rand_range(150, 250)


func _physics_process(_delta):
	match state:
		IDLE:
			idle()
		MOVE:
			move()
		ATTACK:
			attack()
		HIT:
			hit()
	
	phys_proc_cleanup()


func phys_proc_cleanup():
	if health <= 0:
		die()
		
	if state != ATTACK:
		if direction.x < 0:
			animSkeleton.scale.x = 1
		elif direction.x > 0:
			animSkeleton.scale.x = -1


# IDLE FUNCTIONS ———————————————————————————————————————————————————————————————
func idle():
	animPlayer.play("idle")
	
	if player.good_dream_state:
		state = MOVE
	
	if frame >= idle_frame_limit:
		cooling_down = false
		frame = 0
		state = MOVE
	frame += 1


# MOVEMENT FUNCTIONS ———————————————————————————————————————————————————————————
func move():
	animPlayer.play("move")
	if global_position.x < LEFT_BORDER:
		direction = Vector2.RIGHT
	elif global_position.x > RIGHT_BORDER:
		direction = Vector2.LEFT
	elif global_position.y > BOTTOM_BORDER:
		direction = Vector2.UP
	elif player.good_dream_state:
		direction = global_position.direction_to(Vector2(flee_target_x,0))
	elif cooling_down:
		
		if !found_cool_down_pos:
			found_cool_down_pos = true
			cool_down_pos = Vector2(rand_range(LEFT_BORDER, RIGHT_BORDER), rand_range(400, 520))
		
		direction = global_position.direction_to(self.cool_down_pos)
		if global_position.distance_to(cool_down_pos) < 100:
			frame = 0
			state = IDLE
	else:
		direction = global_position.direction_to(player.global_position)
	
	velocity += direction * ACCELERATION
	velocity.y = clamp(velocity.y, -MAX_VEL_Y, MAX_VEL_Y)
	velocity.x = clamp(velocity.x, -MAX_VEL_X, MAX_VEL_X)
# warning-ignore:return_value_discarded
	move_and_slide(velocity)


# ATTACK FUNCTIONS —————————————————————————————————————————————————————————————
func _on_DetectionArea_body_entered(body):
	if body.collision_layer == 1 and !cooling_down:
		animPlayer.play("charging")
		charging = true
		cooling_down = true
		found_cool_down_pos = false
		state = ATTACK


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "charging":
		frame = 0
		hurtbox_col.disabled = false
		charging = false
		last_player_pos = player.global_position


func attack():
	if charging:
		if global_position.direction_to(player.global_position).x <= 0:
			animSkeleton.scale.x = 1
		else:
			animSkeleton.scale.x = -1
	else:
		animPlayer.play("attack")
		
		direction = global_position.direction_to(last_player_pos)
		velocity = direction * ATTACK_SPEED
		velocity = velocity.clamped(ATTACK_SPEED)
# warning-ignore:return_value_discarded
		move_and_slide(velocity)
		
		if frame >= 10 or global_position.distance_to(last_player_pos) < 20:
			hurtbox_col.disabled = true
			frame = 0
			state = MOVE
		frame += 1


# HIT FUNCTIONS —————————————————————————————————————————————————————————————
func _on_Hitbox_area_entered(area):
	frame = 0
	_Camera.shake(30, .4, 120)
	hitSound.pitch_scale = 1 + rand_range(0.05, 0.1)
	hitSound.play()
	
	if state == HIT or charging:
		last_state = MOVE
		charging = false
		cooling_down = false
	else:
		last_state = state
	
	if area.collision_layer == 128:
		if area.parried:
			state = HIT
			health -= 1
	else:
		state = HIT
		health -= 1
	
	if state == HIT:
		var end_hit_pos = global_position + (100 * -global_position.direction_to(area.global_position))
		end_hit_pos.x = clamp(end_hit_pos.x, 90, 990)
		end_hit_pos.y = clamp(end_hit_pos.y, 0, 1015)
		
		animPlayer.play("hit")
		hitTween.interpolate_property(self, "global_position", global_position, 
		end_hit_pos, 0.4, Tween.TRANS_EXPO, Tween.EASE_OUT, 0.05)
		hitTween.start()


func _on_HitTween_tween_all_completed():
	if global_position.x > 990:
		global_position.x = 990
	if global_position.x < 90:
		global_position.x = 90


func hit():
	if frame >= HIT_FRAME_LIMIT:
		frame = 0
		state = last_state
	frame += 1


func die():
	if !dead:
		dead = true
		var death_ins = death_TSCN.instance()
		death_ins.global_position = global_position
		get_parent().add_child(death_ins)
		
		call_deferred("remove_child", deathSound)
		get_parent().call_deferred("add_child", deathSound)
		deathSound.play()
		
		_Camera.shake(200, 0.4, 200)
		emit_signal("enemy_died")
		queue_free()
