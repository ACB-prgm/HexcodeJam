extends CanvasLayer

var perry = preload("res://Scenes/Perry/Perry.tscn")
var good_dream = preload("res://Scenes/GoodDreams/GoodDreams.tscn")
var frames = 0


func _ready():
	randomize()
	Foreground.follow_viewport_enable = true
	Transitioner._in(true)
	
	var perr = perry.instance()
	if Globals.player_death_pos:
		perr.global_position = Vector2(Globals.player_death_pos.x, 915)
	else:
		perr.global_position = Vector2(540, 915)
	add_child(perr)
	
	perr.connect("player_hit", $HUD, "_on_player_hit")


func _physics_process(_delta):
	frames += 1
	if frames == 2000:
		spawn_good_dream(Vector2(rand_range(250, 850), -100))
		frames = 0
		

func spawn_good_dream(location:Vector2):
	var new_good_dream = good_dream.instance()
	new_good_dream.global_position = location
	self.add_child(new_good_dream)
