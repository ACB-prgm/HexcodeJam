extends CanvasLayer


const EIGHT_HOURS = 480
const TWELVE_59 = 779
const ONE = 60
const SEVEN = 420
const TOTAL_MINUTES = 659.0

onready var animPlayer = $AnimationPlayer
onready var timeLabel = $TimeLabel
onready var nightLabel = $NightLabel

var player_dead:bool = false
var night = 0
var minutes = EIGHT_HOURS
var am_pm = "P"
var add_amount = 0

var num_enemies = 0 # ALL SPAWNED ENEMIES + ALL ENEMIES IN STACK
var num_active_enemies = 0 # SPAWNED ENEMIES ONLY
const SPAWN_LIMIT = 10
var enemies_stack = []


func _ready():
	Music._in("GAME_HAPPY")
	randomize()
	yield(get_tree().create_timer(1.0), "timeout")
	next_level()


func next_level():
	$AlarmClock.play(7)
	yield(get_tree().create_timer(1.0), "timeout")
	num_enemies = 0
	num_active_enemies = 0
	night += 1
	nightLabel.set_text("night %s" % night)
	
	yield(get_tree().create_timer(1.0), "timeout")
	create_enemy_stack()
	spawn_enemies()
	reset_clock()
	
	Globals.player.health = 5
	animPlayer.play("happy")
	


func create_enemy_stack():
	var spawn_info = null
	if night <= 4:
		spawn_info = EnemyWaveInfo.Nights.get(night)
	else:
		spawn_info = {
						1 : int(rand_range(night/5, night/2)),
						2 : int(rand_range(night/3, night)),
						3 : int(rand_range(night/3, night)),
					}
	
	for enemy in range(1, 4):
		var num_enemies_tospawn = spawn_info.get(enemy)
		num_enemies += num_enemies_tospawn
		
		if num_enemies_tospawn == 0:
			continue
		else:
			for enemy_to_spawn in num_enemies_tospawn:
				enemies_stack.append(enemy)
	enemies_stack.shuffle()


func spawn_enemies():
	var temp_stack = []
	
	for enemy in enemies_stack:
		if num_active_enemies >= SPAWN_LIMIT:
			break
		else:
			var enemy_instance = EnemyWaveInfo.enemies.get(enemy).instance()
			enemy_instance.global_position = random_spawn_loc(enemy)
			enemy_instance.connect("enemy_died", self, "_on_enemy_died")
			get_parent().add_child(enemy_instance)
			
			temp_stack.append(enemy)
			num_active_enemies += 1
	
	for enemy in temp_stack:
		enemies_stack.erase(enemy)



func random_spawn_loc(enemy_type:int = 1) -> Vector2: # randomly generates a Vector2 outside the viewport
	var X = 0
	var flip = rand_range(0.0, 10.0)
	if flip >= 5.0: # RIGHT SIDE
		X = 1080 + rand_range(40, 200)
	else: # LEFT SIDE
		X = 0 - rand_range(40, 200)
	
	var Y = 0
	if enemy_type == 1:
		Y = rand_range(70, 83)
	elif enemy_type == 3:
		Y = -50
		X = rand_range(-50, 1130)
	else:
		Y = rand_range(95, 110)
	
	return Vector2(X, Y)


func _on_enemy_died():
	num_enemies -= 1
	num_active_enemies -= 1
	if num_active_enemies <= int(rand_range(5, 9)):
		spawn_enemies()
	elif num_active_enemies <= 5:
		spawn_enemies()
	
	set_time()
	
	if num_enemies <= 0:
		next_level()


# CLOCK FUNCTIONS ——————————————————————————————————————————————————————————————
func reset_clock():
	minutes = EIGHT_HOURS
	am_pm = "P"
	add_amount = ceil(TOTAL_MINUTES / num_enemies)
	set_time(false)


func set_time(adding=true):
	# must remove enemies from list and count to num_enemies
	if adding:
		minutes += int(add_amount)
	
	if minutes > TWELVE_59 and am_pm == "P":
		am_pm = "A"
		minutes = 60
		add_amount = ceil(360 / num_enemies)
	
	var rep_minutes = minutes % 60
	if rep_minutes < 10:
		rep_minutes = "0%s" % str(rep_minutes)
	
	timeLabel.set_text("%s:%s %sM" % [minutes / 60, rep_minutes, am_pm])


# PLAYER HEALTH FUNCTIONS ——————————————————————————————————————————————————————
func _on_player_hit(player_health):
	if player_health >= 4:
		animPlayer.play("happy")
	elif player_health >= 2:
		animPlayer.play("neutral")
	elif player_health == 1:
		animPlayer.play("scared")
	elif player_health <= 0 and !player_dead:
		player_dead = true
		Music.stop_all_music()
		Transitioner._out(get_tree(), "res://Scenes/TitleScreen/TitleScreen.tscn")
