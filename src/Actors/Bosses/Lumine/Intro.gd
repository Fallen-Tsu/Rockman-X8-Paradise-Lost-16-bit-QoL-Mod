extends GenericIntro
onready var sprite: AnimatedSprite = $"../animatedSprite"
onready var tween := TweenController.new(self,false)
onready var space: Node = $"../Space"
onready var rotating_crystals: Node2D = $"../RotatingCrystals"

const song_intro_og = "res://src/Sounds/OST - Lumine - Intro.ogg"
const song_loop_og = "res://src/Sounds/OST - Lumine - Loop.ogg"
var song_intro: AudioStream
var song_loop: AudioStream
export var song_intro_alt : AudioStream
export var song_loop_alt : AudioStream
export var boss_bar : Texture

func _ready():
	._ready()
	if Configurations.get("AltMusic"):
		song_intro = song_intro_alt
		song_loop = song_loop_alt
	else:
		song_intro = preload(song_intro_og)
		song_loop = preload(song_loop_og)

func connect_start_events() -> void:
	call_deferred("prepare_for_intro")
	Tools.timer(1,"execute_intro",self)
	#call_deferred("execute_intro")

func prepare_for_intro() -> void:
	sprite.position.y = -250
	character.global_position.y = raycast_downward(256)["position"].y
	Log("Preparing for Intro")

func _Update(delta):
	if attack_stage == 0:
		play_animation("intro_descent")
		tween.create(Tween.EASE_OUT,Tween.TRANS_QUAD)
		tween.add_attribute("position:y",0,3.0,sprite)
		tween.add_callback("next_attack_stage")
		next_attack_stage()
	
	# attack_stage == 1 is descent
	
	elif attack_stage == 2:
		play_animation("intro_idle")
		next_attack_stage()
	
	elif attack_stage == 3 and timer > 1:
		play_animation("open")
		start_dialog_or_go_to_attack_stage(5)
	
	elif attack_stage == 4:
		if seen_dialog():
			next_attack_stage()

	elif attack_stage == 5 and timer > 0.75:
		play_animation("fly_start")
		go_to_center()
		rotating_crystals.expand_crystals()
		GameManager.music_player.play_song_wo_fadein(song_loop,song_intro)
		Event.emit_signal("set_boss_bar",boss_bar)
		Event.emit_signal("boss_health_appear", character)
		next_attack_stage()
	
	# attack_stage == 6 is going to center
	
	elif attack_stage == 7:
		#GameManager.player.stop_forced_movement()
		#Tools.timer(0.1,"stop_forced_movement",)
		EndAbility()
			

func go_to_center() -> void:
	var pos = space.get_center()
	var time_to_return = space.time_to_position(pos,60)
	tween.create(Tween.EASE_IN_OUT,Tween.TRANS_QUAD)
	tween.add_attribute("global_position",pos,time_to_return,character)
	tween.add_callback("next_attack_stage")
