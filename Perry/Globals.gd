extends Node


var player: Perry = null
var player_death_pos = Vector2(540, 960)


var highscore = 1


# SAVE/LOAD
const SAVE_DIR = 'user://saves/'

var save_path = SAVE_DIR + 'save.dat'


func _ready():
	load_data()

func save_data():
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
	
	var file = File.new()
	var error = file.open_encrypted_with_pass(save_path, File.WRITE, 'abigail')
	if error == OK:
		file.store_var(highscore)
		file.close()

func load_data():
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open_encrypted_with_pass(save_path, File.READ, 'abigail')
		if error == OK:
			highscore = file.get_var()

			file.close()
	else:
		print('No Load Data')
