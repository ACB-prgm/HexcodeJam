extends Control


export var page: int = 1


func _hide():
	hide()
	$Perries.hide()


func _show():
	show()
	$Perries.show()
