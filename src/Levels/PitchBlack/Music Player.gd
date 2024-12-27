extends "res://src/Levels/music_player.gd"


var alarm_intro: AudioStream
var alarm_song: AudioStream
const alarm_intro_og = "res://src/Sounds/OST - PitchBlack - AlarmIntro.ogg"
const alarm_song_og = "res://src/Sounds/OST - PitchBlack - AlarmLoop.ogg"
export var alarm_intro_alt : AudioStream
export var alarm_song_alt : AudioStream
var timer = Timer.new()
var played_alarm := false

func _ready() -> void:
	if Configurations.get("AltMusic"):
		alarm_intro = alarm_intro_alt
		alarm_song = alarm_song_alt
	else:
		alarm_intro = preload(alarm_intro_og)
		alarm_song = preload(alarm_song_og)
	Event.listen("alarm",self,"play_alarm_song")
	Event.listen("turn_off_alarm",self,"on_reset_lights")

func on_reset_lights() -> void:
	if played_alarm:
		start_fade_out()
		timer.connect("timeout",self,"play_stage_song")
		timer.one_shot = true
		add_child(timer)
		timer.start()
		played_alarm = false

func play_alarm_song() -> void:
	played_alarm = true
	play_song(alarm_song,alarm_intro)

