extends KinematicBody2D
class_name Perry


const ACCELERATION = 100 # 1/12 of second to reach max_vel
const DECCELERATION = 33
const JUMP_FORCE = 1100
const GRAVITY = 50
const MAX_FALL_SPEED = 1000
const MAX_VELOCITY = 500

onready var animTree = $AnimationTree
onready var animState = animTree.get("parameters/playback")
onready var animSkeleton = $AnimatedSkeleton
onready var animationPlayer = $AnimatedSkeleton/AnimationPlayer
onready var wallJumpTimer = $WallJumpTimer
onready var hurtbox_col = $Hurtbox/CollisionShape2D
onready var parryArea_col = $ParryArea/CollisionShape2D
onready var parry_detectionArea = $ParryDetectionArea
onready var detectionArea = $DetectionArea
onready var attackTimer = $AttackTimer
onready var attackTween = $AttackTween

onready var jumpSound = $JumpSound
onready var parrySound = $ParrySound
onready var parryHitSound = $ParryHitSound
onready var attackSound = $AttackSound
onready var footstepSound = $FootStepSound
onready var sounds = {
	"FOOTSTEP" : footstepSound
}

var movement_paused:bool = false
var attack_missed: bool = false
var facing_left:bool = true
var can_wall_jump:bool = false setget, get_can_wall_jump
var can_attack_or_parry:bool = true
var good_dream_state:bool = false
var has_bounced: bool = false
var input_vector: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var health = 5
var goodDreamCharging = preload("res://Scenes/GoodDreams/GoodDreamsCharging.tscn")
var dashLine = preload("res://Scenes/Perry/DashLine.tscn")

signal player_hit(health)
signal attack_finished

enum {
	NORMAL,
	PARRY,
	GOOD_DREAM,
	HIT,
	DEAD
}
export var state = NORMAL


func _ready():
	$AnimatedSprite.frame = 9
	Globals.player = self
	hurtbox_col.disabled = true
	parryArea_col.disabled = true
	animTree.active = true
	randomize()


func _physics_process(_delta):
	match state:
		NORMAL:
			good_dream_state = false
			attack()
			movement()
			parry()
		PARRY:
			good_dream_state = false
			pass
		GOOD_DREAM:
			good_dream_state = true
			charging_good_dream()
		HIT:
			hit()
		DEAD:
			animState.travel("Hit")

	animate()


# MOVEMENT FUNCTIONS ———————————————————————————————————————————————————————————
func movement():
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if !movement_paused:
		if input_vector != Vector2.ZERO:
			if input_vector.x > 0:
				facing_left = false
			else:
				facing_left = true
			
			velocity += input_vector * ACCELERATION
			velocity.x = clamp(velocity.x, -MAX_VELOCITY, MAX_VELOCITY)
		else:
			velocity.x = move_toward(velocity.x, 0, DECCELERATION)
	
		var on_ground = is_on_floor()
		if !on_ground:
			velocity.y += GRAVITY
			velocity.y = clamp(velocity.y, -JUMP_FORCE, MAX_FALL_SPEED)
			
			if is_on_wall():
				if Input.is_action_just_pressed("ui_jump") and self.can_wall_jump:
					velocity = Vector2(JUMP_FORCE * animSkeleton.scale.x, -JUMP_FORCE)
					movement_paused = true
					jumpSound.pitch_scale = 1.1 + rand_range(-0.1, 0.1)
					jumpSound.play()
					wallJumpTimer.start()
			
		if on_ground:
			attack_missed = false
			can_wall_jump = true
			
			velocity.y = clamp(velocity.y, 5, 5)
			if Input.is_action_just_pressed("ui_jump"):
				jumpSound.pitch_scale = 1.1 + rand_range(-0.1, 0.1)
				jumpSound.play()
				velocity.y = -JUMP_FORCE
		
# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2(0, -1))

func get_can_wall_jump():
	if can_wall_jump:
		can_wall_jump = false
		return true
	else:
		return false

func _on_WallJumpTimer_timeout():
	movement_paused = false


# ATTACK FUNCTIONS —————————————————————————————————————————————————————————————
func attack():
	if !can_attack_or_parry:
		hurtbox_col.set_deferred("disabled", true)
	
	if Input.is_action_just_pressed("ui_attack") and can_attack_or_parry and !attack_missed:
		hurtbox_col.set_deferred("disabled", false)
		attackTimer.start()
		can_attack_or_parry = false
		movement_paused = true
			
		if !detectionArea.get_overlapping_areas(): # miss
			attack_missed = true
			velocity = Vector2.ZERO
		else:
			var target = detectionArea.get_overlapping_areas()[0]
			rotation = animSkeleton.global_position.angle_to_point(target.global_position)
			
			var dir_to_target = global_position.direction_to(target.global_position)
			velocity = (dir_to_target * 750)
			
			var dash_INS = dashLine.instance()
# warning-ignore:return_value_discarded
			connect("attack_finished", dash_INS, "_on_attack_finished")
			dash_INS.global_position = global_position
			get_parent().add_child(dash_INS)
			
			animSkeleton.scale.x = 1
			if dir_to_target.x >= 0:
				animSkeleton.scale.y = -1
			else:
				animSkeleton.scale.y = -1
		
		attackSound.pitch_scale = 1 + rand_range(-0.1, 0.1)
		attackSound.play()

func _on_AttackTimer_timeout():
	movement_paused = false
	can_attack_or_parry = true
	animSkeleton.scale.y = 1
	
	attackTween.interpolate_property(animSkeleton, "modulate", modulate, 
	Color(1,1,1,1), 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	attackTween.interpolate_property(self, "rotation", rotation, 0, 
	0.1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	attackTween.start()
	
	emit_signal("attack_finished")


# ANIMATIONS ———————————————————————————————————————————————————————————————————
func animate():
	match state:
		NORMAL:
			if animState.get_current_node() == "Wall_sliding":
				$AnimatedSkeleton/Torso.flip_h = true
				$AnimatedSkeleton/Leg2.flip_h = true
			else:
				$AnimatedSkeleton/Torso.flip_h = false
				$AnimatedSkeleton/Leg2.flip_h = false
			
			if !is_on_floor():
				if is_on_wall():
					animState.travel("Wall_sliding")
				else:
					if velocity.y > 0: #falling
						animState.travel("Falling")
						animTree.set("parameters/Falling/BlendSpace2D/blend_position", input_vector)
					else: #jumping
						animState.travel("Jumping")
						animTree.set("parameters/Jumping/BlendSpace2D/blend_position", input_vector)
			else:
				animState.travel("Running")
				animTree.set("parameters/Running/BlendSpace2D/blend_position", input_vector)
			
			if !can_attack_or_parry:
				animState.travel("Attack_1")
		
			if !movement_paused:
				if facing_left:
					animSkeleton.scale.x = 1
				else:
					animSkeleton.scale.x = -1
		PARRY:
			pass
		GOOD_DREAM:
			animState.travel("Good_dream_charging")

func randomize_pitch(audio:String, original_pitch:float, magnitude:float=0.1) -> void:
	var player = sounds.get(audio)
	player.pitch_scale = original_pitch + rand_range(-magnitude, magnitude)
	player.play()
	

# GOOD DREAM FUNCTIONS —————————————————————————————————————————————————————————
func _on_good_dream_opened():
	state = GOOD_DREAM
	velocity = Vector2.ZERO
	
	var charging_animation = goodDreamCharging.instance()
	charging_animation.connect("good_dream_ended", self, "_on_good_dream_ended")
	charging_animation.global_position = global_position
	get_parent().add_child(charging_animation)

func _on_good_dream_ended():
	state = NORMAL
	animState.travel("Falling")
	animSkeleton.set_modulate(Color(1,1,1,1))

func charging_good_dream():
	pass


# PARRY FUNCTIONS ——————————————————————————————————————————————————————————————
func parry():
	if Input.is_action_just_pressed("ui_parry"):
		if parry_detectionArea.get_overlapping_areas():
			parrySound.pitch_scale = 1 + rand_range(0, 0.09)
			parrySound.play()
			animState.travel("Parry")
			parryArea_col.disabled = false
			_Camera.shake(30, .4, 120)
			movement_paused = true
			state = PARRY


func parrying():
	velocity = Vector2.ZERO


func parry_finished():
	velocity = input_vector * JUMP_FORCE + Vector2(0, -300)
	parryArea_col.disabled = true
	movement_paused = false
	state = NORMAL


func _on_ParryArea_area_entered(_area):
	parryHitSound.pitch_scale = 1 + rand_range(-0.05, 1.5)
	parryHitSound.play()


# HIT FUNCTIONS ————————————————————————————————————————————————————————————————
func _on_Hitbox_area_entered(_area):
	if state != HIT and state != PARRY:
		_Camera.shake(200, 0.4, 200)
		health -= 1
		emit_signal("player_hit", health)
		animState.travel("Hit")
		
		state = HIT
		velocity = Vector2(200, -500)


func hit():
	velocity.y += GRAVITY
	
	if is_on_floor():
		if !has_bounced:
			has_bounced = true
			_Camera.shake(100)
			velocity = Vector2(200, -500)
		else:
			if health <= 0:
				state = DEAD
				velocity = Vector2.ZERO
				Globals.player_death_pos = global_position
			else:
				state = NORMAL
				has_bounced = false
	
# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP)
