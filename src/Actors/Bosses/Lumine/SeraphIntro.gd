extends GenericIntro

var intro : AudioStream
var loop : AudioStream
const intro_og = "res://src/Sounds/OST - SeraphLumine - Intro.ogg"
const loop_og = "res://src/Sounds/OST - SeraphLumine - Loop.ogg"
export var intro_alt : AudioStream
export var loop_alt : AudioStream
onready var sprite: AnimatedSprite = $"../animatedSprite"
onready var tween := TweenController.new(self,false)
onready var front_wings: AnimatedSprite = $"../frontWings"
onready var back_wings: AnimatedSprite = $"../backWings"
onready var windspark: Sprite = $windspark
onready var woosh: AudioStreamPlayer2D = $woosh
onready var flap: AudioStreamPlayer2D = $flap
onready var feather_particles: Particles2D = $"../animatedSprite/feather_particles"
onready var feather_explosion: Particles2D = $"../feather_explosion"
onready var move_feathers: Particles2D = $"../animatedSprite/move_feathers"
onready var space: Node = $"../Space"
onready var flash_2: Sprite = $flash2

func _ready():
	if Configurations.get("AltMusic"):
		intro = intro_alt
		loop = loop_alt
	else:
		intro = preload(intro_og)
		loop = preload(loop_og)
func connect_start_events() -> void:
	call_deferred("prepare_for_intro")
	call_deferred("set_visibility",false)
	Tools.timer(6.5,"execute_intro",self) #6.5

func prepare_for_intro() -> void:
	sprite.position.x = -450
	sprite.position.y = -70
	Log("Preparing for Intro")
	Event.emit_signal("lumine_went_seraph")
	
func execute_intro() -> void:
	set_visibility(true)
	ExecuteOnce()

func set_visibility(value : bool):
	sprite.visible = value
	front_wings.visible = value
	back_wings.visible = value
	
func _Setup():
	space.define_arena()
	
func _Update(delta):
	if attack_stage == 0:
		play_animation("forward")
		
		move_feathers.emitting = true
		set_direction(1)
		#character.global_position.y += 10
		tween.create(Tween.EASE_IN,Tween.TRANS_LINEAR,true)
		tween.add_attribute("position:y",-20,.8,sprite)
		tween.add_attribute("position:x",236,.8,sprite)
		tween.set_sequential()
		tween.add_callback("next_attack_stage")
		woosh.play_rp()
		Tools.timer_p(0.3,"screenshake",self,4)
		Tools.timer_p(0.7,"screenshake",self,.4)
		next_attack_stage()
		
	#attack_stage == 1 is tween
	
	elif attack_stage == 2 and timer > .75:
		set_direction(-1)
		woosh.play_rp()
		Tools.timer_p(0.3,"screenshake",self,.7)
		play_animation("forward")
		tween.create(Tween.EASE_OUT,Tween.TRANS_LINEAR,true)
		tween.add_attribute("position:y",0,0.5,sprite)
		tween.add_attribute("position:x",35,0.5,sprite)
		tween.set_sequential()
		tween.add_callback("next_attack_stage")
		next_attack_stage()
		
	#attack_stage == 3 is tween
	
	elif attack_stage == 4:
		tween.create(Tween.EASE_OUT,Tween.TRANS_CUBIC,true)
		tween.add_attribute("position:x",0,0.6,sprite)
		play_animation("forward_end")
		move_feathers.emitting = false
		Tools.timer_p(0.2,"screenshake",self,.8)
		flap.play_rp()
		next_attack_stage()
	
	elif attack_stage == 5 and has_finished_last_animation():
		play_animation("idle")
		next_attack_stage()

	elif attack_stage == 6 and timer > .8:
		GameManager.music_player.play_song_wo_fadein(loop,intro)
		play_animation("intro_start")
		#flap.play_rp()
		show_flash = true
		next_attack_stage()

	elif attack_stage == 7 and timer > 1:
		flash()
		tween.attribute("self_modulate:a",0.0,1.6,flash_2)
		play_animation("intro")
		Tools.timer(.75,"show_health",self)
		feather_explosion.restart()
		feather_particles.emitting = true
		$flash.start()
		windspark.emit()
		woosh.play_rp()
		screenshake(.9)
		var i = 0.3
		while i < 2:
			Tools.timer_p(i,"screenshake",self,.3)
			i += .3
		next_attack_stage()

	elif attack_stage == 8 and timer > 3:
		play_animation("intro_end")
		show_flash = false
		Tools.timer_p(0.3,"screenshake",self,.8)
		flap.play_rp()
		next_attack_stage()

	elif attack_stage == 9 and has_finished_last_animation():
		play_animation("idle")
		EndAbility()

func show_health():
	Event.emit_signal("boss_health_hide")
	Event.emit_signal("boss_health_appear", character)

var show_flash:= false

func flash():
	if show_flash:
		flash_2.start()
		Tools.timer(0.1,"flash",self)
	

func screenshake(value := 2.0):
	.screenshake(value)
