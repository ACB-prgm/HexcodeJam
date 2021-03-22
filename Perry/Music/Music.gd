extends Node

onready var startMusicTween = $StartMusicTween
onready var stopMusicTween = $StopMusicTween

onready var titleMusic = $TitleMusic
onready var inGameMusic_Happy = $InGameMusicHappy
onready var inGameMusic_Sad = $InGameMusicSad

var Music_enabled = true
var songs_to_stop = []
var songs_playing = []

onready var Tracks = {
	"TITLE" : {
		"song": titleMusic,
		"start_time": 0.0
	},
	"GAME_HAPPY": {
		"song": inGameMusic_Happy,
		"start_time": 37.8
	},
	"GAME_SAD": {
		"song": inGameMusic_Sad,
		"start_time": 57.0
	}
}


func _in(track, tween_time=1):
	var song = Tracks.get(track).get("song")
	
	if Music_enabled:
		if songs_to_stop.has(song):
			songs_to_stop.erase(song)
			stopMusicTween.stop(song)
		songs_playing.append(song)
		
		startMusicTween.interpolate_property(song, 'volume_db', -35.0, 0.0, tween_time, 
		Tween.TRANS_SINE, Tween.EASE_IN)
		startMusicTween.start()
		
		song.call_deferred("play", Tracks.get(track).get("start_time"))
	else:
		pass

func _out(track, tween_time=3):
	var song = Tracks.get(track).get("song")
	
	if song.playing:
		songs_playing.erase(song)
		songs_to_stop.append(song)
		startMusicTween.stop(song)
		
		stopMusicTween.interpolate_property(song, 'volume_db', song.volume_db, -35.0, tween_time, 
		Tween.TRANS_SINE, Tween.EASE_OUT)
		stopMusicTween.start()

func stop_all_music(fade=true, tween_time=3):
	for song in songs_playing:
		startMusicTween.stop(song)
		if fade:
			stopMusicTween.interpolate_property(song, 'volume_db', song.volume_db,
			-35.0, tween_time, Tween.TRANS_SINE, Tween.EASE_OUT)
			stopMusicTween.start()
		else:
			song.set_deferred('playing', false)
		songs_playing.erase(song)


func get_playing(index=0) -> String:
	if songs_playing:
		for track in Tracks:
			var song = Tracks.get(track).get("song")
			if  song == songs_playing[index]:
				return track
	return "null"


func _on_StopMusicTween_tween_completed(_object, _key):
	for song in songs_to_stop:
		song.stop()
		songs_to_stop.erase(song)
