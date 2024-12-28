extends Node2D
onready var firenoise: AudioStreamPlayer2D = $firenoise

export var charge_color1 : Color
export var charge_color2 : Color
var song_intro: AudioStream
var song_loop: AudioStream
const song_intro_og = "res://src/Sounds/OST - Ending - Intro.ogg"
const song_loop_og = "res://src/Sounds/OST - Ending - Loop.ogg"
export var song_intro_alt : AudioStream
export var song_loop_alt : AudioStream
export var text_second_dialog : Resource
onready var dialog_box: Label = $DialogBox
onready var screencover: Sprite = $screencover
onready var x: AnimatedSprite = $X
onready var charge_shot: AnimatedSprite = $ChargeShot
onready var lumine: AnimatedSprite = $Lumine
onready var lflash: Sprite = $Lumine/flash
onready var remains: Particles2D = $Lumine/remains_particles
onready var explosions: Particles2D = $Lumine/explosions
onready var explode: AudioStreamPlayer2D = $Lumine/explode
onready var shot: AudioStreamPlayer2D = $ChargeShot/shot
onready var charge: AudioStreamPlayer2D = $X/charge
onready var explode_2: AudioStreamPlayer2D = $Lumine/explode2
onready var beam_outvfx: AudioStreamPlayer2D = $X/beam_out
onready var charge_vfx: AnimatedSprite = $X/ChargeVFX
onready var musicplayer: AudioStreamPlayer = $"Music Player"
onready var shockwave: Sprite = $Lumine/shockwave
onready var burnt_floor: Sprite = $Lumine/burnt_floor
onready var shot2: AudioStreamPlayer2D = $X/shot

onready var tween := TweenController.new(self,false)

func _ready() -> void:
	if Configurations.get("AltMusic"):
		song_intro = song_intro_alt
		song_loop = song_loop_alt
	else:
		song_intro = preload(song_intro_og)
		song_loop = preload(song_loop_og)
	screencover.visible = true
	tween.attribute("volume_db",-35,2,firenoise)
	Tools.timer(2,"fade_in",self)
	Tools.timer(8,"start_dialog",self)
	Event.connect("character_talking",self,"on_talk")

func on_talk(character_name : String):
	if character_name == "MegaMan X":
		x.play("talk")
	else:
		x.play("idle")

func start_dialog():
	musicplayer.play_song(song_loop,song_intro)
	dialog_box.startup()

func fade_in():
	tween.attribute("modulate:a",0.0,5.0,screencover)

func _on_dialog_concluded() -> void:
	if not second_dialog:
		#after_explosion()
		Tools.timer(1.0,"start_charge",self)
	else:
		Tools.timer(1.0,"beam_out",self)

func start_charge() -> void:
	x.material.set_shader_param("Color",charge_color1)
	x.material.set_shader_param("Charge",1.0)
	x.play("shot")
	charge.play()
	charge_vfx.visible = true
	Tools.timer(1.5,"next_charge",self)

func next_charge() -> void:
	x.material.set_shader_param("Color",charge_color2)
	charge_vfx.play("Heavy")
	charge_vfx.modulate = Color.khaki
	Tools.timer(4.0,"fire",self)

func fire() -> void:
	x.material.set_shader_param("Charge",0.0)
	charge_shot.visible = true
	x.frame = 0
	shot.play()
	Tools.timer(0.16,"play",shot2,null,true)
	tween.attribute("position:x",600,1.0,charge_shot)
	Tools.timer(3.5,"end_fire",self)
	Tools.timer(0.15,"quick_pause",self)
	Tools.timer(0.18,"lumine_explosion",self)
	charge_vfx.visible = false
	charge.stop()

func end_fire() -> void:
	x.play("recover")

func quick_pause() -> void:
	lflash.start()
	lumine.material.set_shader_param("Flash",1.0)
	GameManager.pause("lumine_explosion")
	explode.play()
	Tools.timer(0.85,"unquickpause",self,null,true)

func unquickpause() -> void:
	GameManager.unpause("lumine_explosion")

func lumine_explosion() -> void:
	explosions.emitting = true
	lumine.self_modulate.a = 0.0
	remains.emitting = true
	Tools.timer(1.5,"lumine_explosion_finish",self)
	burnt_floor.visible = true
	#emit_shockwave()
	remaining_explosions()
	
var extra_explosions := true
func remaining_explosions():
	if extra_explosions:
		explode_2.play_rp()
		Tools.timer(.4,"remaining_explosions",self)

func lumine_explosion_finish():
	extra_explosions = false
	explosions.emitting = false
	remains.emitting = false
	Tools.timer(3.0,"after_explosion",self)

func after_explosion():
	x.play("idle")
	Tools.timer(0.5,"start_second_dialog",self)

func start_second_dialog():
	second_dialog = true
	dialog_box.dialog_tree = text_second_dialog
	dialog_box.startup()

func beam_out():
	x.play("beam_in",true)
	beam_outvfx.play()
	Tools.timer(0.15,"pull_x_up",self)

func pull_x_up():
	x.play("beam")
	tween.attribute("position:y",-600,1.0,x)
	Tools.timer(1.0,"fade_out",self)

func fade_out():
	screencover.visible = true
	screencover.material.blend_mode = 0
	screencover.modulate = Color.black
	screencover.modulate.a = 0.0
	tween.attribute("modulate:a",1.0,3.0,screencover)
	tween.attribute("volume_db",-50,10.0,musicplayer)
	tween.attribute("volume_db",-80,6,firenoise)
	tween.add_callback("go_to_credits")
	musicplayer.fade_in = false
	second_dialog = true

func go_to_credits():
	GameManager.go_to_credits()

var second_dialog := false

func emit_shockwave():
	shockwave.visible = true
	tween.attribute("scale:y",10,.3,shockwave)
	tween.attribute("scale:x",.4,.3,shockwave)
	tween.attribute("modulate:a",0,.4,shockwave)
