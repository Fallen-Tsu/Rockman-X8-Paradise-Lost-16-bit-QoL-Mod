extends AttackAbility

export var death_walls : PackedScene
const music_og = "res://src/Sounds/OST - ParadiseLost.ogg"
export var music_alt : AudioStream
var music: AudioStream
onready var space: Node = $"../Space"
onready var tween := TweenController.new(self,false)
var walls : Array
onready var feather_particles: Particles2D = $"../animatedSprite/feather_particles"
onready var feather_decay: Particles2D = $"../feather_decay"
onready var damage: Node2D = $"../Damage"
onready var dot: Node2D = $"../DamageOnTouch"
onready var flap: AudioStreamPlayer2D = $flap

func _ready():
	if Configurations.get("AltMusic"):
		music = music_alt
	else:
		music = preload(music_og)

func _Setup():
	go_to_center()
	GameManager.music_player.start_fade_out()
	set_armor()
	#tween.method("set_armor",.75,1.0,20.0)

func _Update(_delta) -> void:
	reduce_teleport_time(_delta)
	if attack_stage == 1:
		darken_feathers()
		play_animation("scream_prepare")
		Event.emit_signal("lumine_desperation")
		next_attack_stage()

	elif attack_stage == 2 and timer > 1.5:
		play_animation("scream_start")
		flap.play_rp()
		screenshake()
		GameManager.music_player.play_song_wo_fadein(music)
		create_wall(1)
		create_wall(-1)
		next_attack_stage()
		
	elif attack_stage == 3 and has_finished_last_animation():
		play_animation("scream")
		feather_decay.emitting = true
		next_attack_stage()
		
	elif attack_stage == 4 and timer > 2:
		animatedSprite.playing = false
		feather_decay.emitting = false
		next_attack_stage()

	elif attack_stage == 5 and timer > 1:
		animatedSprite.playing = true
		play_animation("scream_end")
		tween.method("set_armor",1.0,3.0,14.0)
		flap.play_rp()
		next_attack_stage()
		
	elif attack_stage == 6 and has_finished_last_animation():
		play_animation("idle")
		character.z_index = 22
		next_attack_stage()
		
	
	elif attack_stage == 7 and timer > teleport_interval:
		play_animation("teleport_out")
		dot.deactivate()
		damage.deactivate()
		next_attack_stage()

	elif attack_stage == 8 and timer > 0.6:
		character.global_position = get_next_position()
		turn_and_face_player()
		play_animation("teleport_in")
		damage.activate()
		next_attack_stage()
	
	elif attack_stage == 9 and has_finished_last_animation():
		play_animation("idle")
		dot.activate()
		go_to_attack_stage(7)
 
var teleport_interval := 1.0

func reduce_teleport_time(delta):
	if attack_stage >= 7:
		
		teleport_interval = clamp(  inverse_lerp(1,120,character.current_health) + .3   ,.4,1.0)
		#print(teleport_interval)

func set_armor(value := 0.75):
	character.emit_signal("damage_reduction", value)
	#print("Set dmg_reduction to " +str(value))

var current_pos = 0
func get_next_position():
	var next_pos = space.positions[current_pos]
	current_pos += 1
	if current_pos > space.positions.size() - 1:
		current_pos = 0
	return Vector2(get_horizontal_pos(next_pos.x),next_pos.y)

func get_horizontal_pos(pos_x):
	if pos_x < space.center.x:
		return walls[0].position.x
	else:
		return walls[1].position.x

func create_wall(scalex : int):
	var wall = death_walls.instance()
	var center = GameManager.camera.get_camera_screen_center()
	
	get_tree().current_scene.add_child(wall)
	wall.position = center
	wall.position.x += (210 * scalex)
	wall.scale.x = scalex
	wall.activate()
	walls.append(wall)

func _Interrupt():
	._Interrupt()
	animatedSprite.playing = true
	feather_decay.emitting = false
	for wall in walls:
		wall.deactivate()

func darken_feathers():
	tween.attribute("modulate",Color.black,3,feather_particles)

func go_to_center() -> void:
	var center = GameManager.camera.get_camera_screen_center() + Vector2(0,-42)
	var time_to_return = space.time_to_position(center,60)
	turn_towards_point(center)
	tween.create(Tween.EASE_IN_OUT,Tween.TRANS_QUAD)
	tween.add_attribute("global_position",center,time_to_return,character)
	tween.add_callback("next_attack_stage")
