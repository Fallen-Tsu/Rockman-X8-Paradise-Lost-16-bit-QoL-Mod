extends GenericIntro

onready var overlay: AnimatedSprite = $"../overlay"
onready var song: AudioStreamPlayer = $song
export var intro_song_alt: AudioStream
onready var tween := TweenController.new(self,false)
onready var battle_song: AudioStreamPlayer = $BattleSong
onready var effect: AudioStreamPlayer = $effect
onready var damage: Node2D = $"../Damage"
export var bar : Texture

func _ready() -> void:
	if Configurations.get("AltMusic"):
		song.stream = intro_song_alt
	call_deferred("play_animation","intro")
	make_invisible()
	Event.listen("character_talking",self,"talk")

func talk(character):
	if character == "Secret2":
		play_animation_once("talk")
	else:
		play_animation_once("intro")

func connect_start_events() -> void:
	Log("Connecting boss door events")
	Event.listen("teleport_to_secret2",self,"prepare_for_intro")
	Event.listen("end_teleport_to_secret2",self,"execute_intro")

func _Setup():
	animatedSprite.visible = false
	Tools.timer(2.0,"start_intro",self)
	GameManager.start_cutscene()
	GameManager.dialog_box.emit_capsule_signal = false
	turn_player_towards_boss()

func start_intro():
	song.play()
	Tools.timer(2.0,"fadein",self)
	
func fadein():
	animatedSprite.visible = true
	tween.attribute("modulate:a",1.0,2.0,overlay)
	tween.add_callback("make_visible")
	tween.add_attribute("modulate:a",0.0,2.0,overlay)
	tween.add_callback("next_attack_stage")

func _Update(delta):
	if attack_stage == 1:
		start_dialog_or_go_to_attack_stage(3)

	elif attack_stage == 2:
		if seen_dialog():
			next_attack_stage()

	elif attack_stage == 3:
		play_animation("intro_end")
		song.stop()
		effect.play()
		next_attack_stage()
		
	elif attack_stage == 4 and timer > 1.1:
		Event.emit_signal("set_boss_bar",bar)
		Event.emit_signal("boss_health_appear", character)
		next_attack_stage()
		
	elif attack_stage == 5 and timer > 1.2:
		battle_song.play()
		damage.can_get_hit = true
		EndAbility()
	pass
