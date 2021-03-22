extends CanvasLayer


var perry = preload("res://Scenes/Perry/Perry.tscn")


func _ready():
	_on_TextureButton_page_button_pressed(false)
	Foreground.follow_viewport_enable = false
	Transitioner._in()
	
	if Globals.player_death_pos:
		var perr = perry.instance()
		perr.state = 4
		perr.global_position = Globals.player_death_pos
		$DeadPerryLayer.add_child(perr)


func _on_TextButton_TextButton_Pressed(): # BACK BUTTON
	Transitioner._out(get_tree(), "res://Scenes/TitleScreen/TitleScreen.tscn")


# PAGES ————————————————————————————————————————————————————————————————————————
onready var pages = $Control/Pages

var page_number = 1


func _on_TextureButton_page_button_pressed(right):
	if right:
		page_number += 1
		if page_number > 3:
			page_number = 3
	else:
		page_number -= 1
		if page_number < 1:
			page_number = 1
	
	for page in pages.get_children():
		if page.page == page_number:
			page._show()
		else:
			page._hide()
