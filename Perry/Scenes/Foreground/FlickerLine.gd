extends TextureRect


var movement_speed = 200
var start_pos_y = 0
var end_pos_y = 1030
var frame = 0
var frame_reset_value = 100


func _ready():
	randomize()


func _physics_process(_delta):
	rect_position.y += movement_speed
	
	if rect_position.y >= end_pos_y:
		rect_position.y = start_pos_y
	
	frame += 1
	
	if frame >= frame_reset_value:
		frame = 0
		frame_reset_value = rand_range(100, 300)
		movement_speed = rand_range(200, 500)
