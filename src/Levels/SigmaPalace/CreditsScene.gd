extends Node2D

var song: AudioStream
const song_og = "res://src/Sounds/OST - MainTheme E-Capcom Remix.ogg"
export var song_alt : AudioStream
onready var tween := TweenController.new(self,false)
onready var visuals: Node2D = $Visuals
onready var credits_bg: Sprite = $CreditsBG
onready var musicplayer: AudioStreamPlayer = $"Music Player"
onready var screencover: Sprite = $screencover
onready var credits: Node2D = $Credits
onready var bottom_cover: Sprite = $bottom_cover
onready var top_cover: Sprite = $top_cover
onready var loop: AudioStreamPlayer2D = $Visuals/ElevatorPlatform/loop

func _ready() -> void:
	if Configurations.get("AltMusic"):
		song = song_alt
	else:
		song = preload(song_og)
	screencover.visible = true
	Tools.timer(1,"fade_in",self)
	Tools.timer(8,"start",self)
	#start_music()
	Tools.timer(2.35,"start_music",self)
	Tools.timer(3.00,"roll_up_credits",self)

func start():
	move_to_the_side()
	move_credits_in()

func start_music():
	musicplayer.play_song(song)

func move_to_the_side():
	tween.create(Tween.EASE_IN_OUT,Tween.TRANS_SINE)
	tween.add_attribute("position:x",-100,6.0,visuals)

func move_credits_in():
	tween.create(Tween.EASE_IN_OUT,Tween.TRANS_SINE)
	tween.add_attribute("position:x",180,6.0,credits_bg)
	#Tools.timer(4.50,"turn_on_covers",self)

func turn_on_covers():
	var final_y = bottom_cover.position.y
	bottom_cover.position.y += 16
	tween.create(Tween.EASE_OUT,Tween.TRANS_SINE)
	tween.add_attribute("position:y",final_y,2.0,bottom_cover)
	
	final_y = top_cover.position.y
	top_cover.position.y -= 16
	tween.create(Tween.EASE_OUT,Tween.TRANS_SINE)
	tween.add_attribute("position:y",final_y,2.0,top_cover)
	bottom_cover.visible = true
	top_cover.visible = true

func fade_in():
	screencover.visible = true
	screencover.modulate = Color.black
	tween.attribute("modulate:a",0.0,3.0,screencover)

func roll_up_credits():
	credits.position.x = 296
	tween.attribute("position:y",-5035 -35,158.0,credits)
	tween.add_callback("fade_out")

func fade_out():
	screencover.visible = true
	tween.attribute("modulate:a",1.0,6.0,screencover)
	tween.add_wait(3)
	tween.attribute("volume_db",-80,6.0,loop)
	if IGT.clocked_all_stages():
		tween.add_callback("go_to_igt",GameManager)
	else:
		tween.add_callback("go_to_disclaimer",GameManager)
		
