extends Area2D

onready var music: AudioStreamPlayer = $"../../Music Player"

var intro: AudioStream
var loop: AudioStream
const intro_og = "res://src/Sounds/OST - SigmaDemo.ogg"
const loop_og = "res://src/Sounds/OST - SigmaDemo - Loop.ogg"
export var intro_alt : AudioStream
export var loop_alt : AudioStream

var started = false

func _ready():
	if Configurations.get("AltMusic"):
		intro = intro_alt
		loop = loop_alt
	else:
		intro = preload(intro_og)
		loop = preload(loop_og)

func _on_body_entered(body: Node) -> void:
	if not started:
		started = true
		music.play_song_wo_fadein(loop,intro)
