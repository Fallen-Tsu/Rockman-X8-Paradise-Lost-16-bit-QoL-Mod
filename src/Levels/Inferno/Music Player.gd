extends "res://src/Levels/music_player.gd"
var lava_intro : AudioStream
var lava_song : AudioStream
const lava_intro_og = "res://src/Sounds/OST - Inferno - LavaIntro.ogg"
const lava_song_og = "res://src/Sounds/OST - Inferno - LavaLoop.ogg"
export var lava_intro_alt : AudioStream
export var lava_song_alt : AudioStream

func _ready():
	if Configurations.get("AltMusic"):
		lava_intro = lava_intro_alt
		lava_song = lava_song_alt
	else:
		lava_intro = preload(lava_intro_og)
		lava_song = preload(lava_song_og)

func play_lava_song() -> void:
	print_debug("Playing Lava Song")
	volume_db = volume + 5
	play_song(lava_song,lava_intro)
