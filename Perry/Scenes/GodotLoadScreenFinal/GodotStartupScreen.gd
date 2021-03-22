extends ColorRect


onready var godotSprite = $Control/GodotAnimatedSprite
onready var tween = $Tween
onready var godotTXT = $Control/Godot
onready var lightFlikceringSound = $LightFlickerSound


func _ready():
	yield(ParticlesCache, "particlesCached")
	lightFlikceringSound.play()
	tween.interpolate_property(godotTXT, 'modulate', Color(1,1,1,0), Color(1,1,1,1),
	 1, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	tween.start()


func _on_AnimationPlayTimer_timeout():
	godotSprite.play()


func _on_GodotAnimatedSprite_animation_finished():
	_Camera.shake(100, 0.4, 100)
	$ChangeSceneTimer.start()


func _on_ChangeSceneTimer_timeout():
	Transitioner._out(get_tree(), "res://Scenes/TitleScreen/TitleScreen.tscn")
