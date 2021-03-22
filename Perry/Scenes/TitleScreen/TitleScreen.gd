extends CanvasLayer


var perry = preload("res://Scenes/Perry/Perry.tscn")


func _ready():
	Foreground.follow_viewport_enable = false
	Transitioner._in()
	
	if Globals.player_death_pos:
		var perr = perry.instance()
		perr.state = 4
		perr.global_position = Globals.player_death_pos
		$DeadPerryLayer.add_child(perr)
	
	if Music.get_playing() != "TITLE":
		Music._in("TITLE")
	


func _on_PlayButton_TextButton_Pressed():
	Transitioner._out(get_tree(), "res://Scenes/PlayLevel/Level.tscn")
	Music._out("TITLE")


func _on_HowToPlayButton_TextButton_Pressed():
	Transitioner._out(get_tree(), "res://Scenes/HowToPlay/HowToPlay.tscn")
