extends Node2D

export var dialog_1 : Resource
export var dialog_2 : Resource
export var dialog_3 : Resource
export var dialog_4 : Resource

var current_dialog := 0

onready var door: AnimatedSprite = $DamagedCraft/Door
onready var craft: AnimatedSprite = $DamagedCraft

onready var tween := TweenController.new(self,false)
onready var door_smoke: Particles2D = $DamagedCraft/Door/smoke
onready var door_smoke_2: Particles2D = $DamagedCraft/Door/smoke2
onready var light: Sprite = $Visuals/light

onready var sigma: AnimatedSprite = $SigmaReploid
onready var sigma2: AnimatedSprite = $SigmaReploid2
onready var sigma3: AnimatedSprite = $SigmaReploid3
onready var sigma4: AnimatedSprite = $SigmaReploid4
onready var lumine: AnimatedSprite = $Lumine
onready var traverse: AudioStreamPlayer2D = $Vile/traverse

var dialogbox: Label
onready var doorhit: AudioStreamPlayer2D = $DamagedCraft/Door/doorhit
onready var explode: AudioStreamPlayer2D = $DamagedCraft/Door/explode
onready var screencover: Sprite = $screencover
onready var explosion_particles: Particles2D = $explosion_particles
onready var background_cover: Sprite = $background_cover

onready var visuals: Node2D = $Visuals
onready var firenoise: AudioStreamPlayer2D = $Visuals/firenoise
onready var vile: AnimatedSprite = $Vile
onready var kidnapped: AnimatedSprite = $Kidnapped
onready var elec_thing: AudioStreamPlayer2D = $Kidnapped/traverse
onready var craft_explosion: Particles2D = $craft_explosion
onready var remains_particles: Particles2D = $remains_particles
onready var explosion_sfx: AudioStreamPlayer2D = $explosion_particles/explosion_sfx
onready var skip_screencover: Sprite = $skip_screencover
onready var vile_theme: AudioStreamPlayer = $vile_theme
onready var lumine_theme: AudioStreamPlayer = $lumine_theme
onready var wall_particles: Particles2D = $background_cover/remains_particles
onready var flash: Sprite = $DamagedCraft/flash
onready var visual_skip: Control = $canvasLayer/VisualSkip

var executing := false

func _ready() -> void:
	Event.connect("noahspark_cutscene_start",self,"start")
	Event.connect("dialog_concluded",self,"on_dialog_end")
	Event.connect("kingcrab_crash",self,"explode_craft")
	Event.emit_signal("disable_victory_ending")
	
	set_physics_process(false)
	if GameManager.was_dialogue_seen(dialog_4):
		get_rid_of_everything_uneeded()
	else:
		blink_light_forever()
	

func start():
	dialogbox = GameManager.dialog_box
	if GameManager.was_dialogue_seen(dialog_4):
		Event.emit_signal("noahspark_cutscene_end")
	else:
		executing = true
		set_physics_process(true)
		dialogbox.resume_character_inputs = false
		Tools.timer(.5,"turn_player_towards_boss",self)
		Tools.timer(.5,"shake_door",self) #2
		Tools.timer(2.0,"shake_door",self)
		Tools.timer(2.0,"shake_craft",self)
		Tools.timer(3.5,"kick_door",self)
		Tools.timer(3.5,"shake_craft",self)

var skip_timer := 0.0

func _physics_process(delta: float) -> void:
	if Configurations.exists("SkipDialog"):
		if Configurations.get("SkipDialog") == false:
			set_physics_process(false)
			return

	if executing:
		visual_skip.fill(skip_timer)
		if Input.is_action_pressed("pause") or Configurations.get("AutoSkipDialog"):
			skip_timer += delta
			visual_skip.fadein()

		elif Input.is_action_just_released("pause"):
			skip_timer = 0
			visual_skip.fadeout()
		
		if skip_timer > 2:
			visual_skip.visible = false
			skip()
			

func skip():
	if executing:
		executing = false
		set_physics_process(false)
		quick_fadeout()
		Tools.timer(0.1,"get_rid_of_everything_uneeded",self)
		Tools.timer(0.2,"quick_fadein",self)
		Tools.timer(1.0,"end_skip",self)
		skip_timer = 0

func get_rid_of_everything_uneeded():
	tween.reset()
	visuals.visible = false
	craft.modulate = Color.darkgray
	explosion_particles.emitting = false
	vile.queue_free()
	lumine.queue_free()
	kidnapped.queue_free()
	sigma.queue_free()
	sigma2.queue_free()
	sigma3.queue_free()
	sigma4.queue_free()
	door.queue_free()
	screencover.queue_free()
	background_cover.queue_free()
	stop_all_music_and_sounds()
	executing = false

func end_skip():
	Event.emit_signal("noahspark_cutscene_end")

func quick_fadeout():
	skip_screencover.visible = true
	skip_screencover.modulate.a = 1.0

func quick_fadein():
	skip_screencover.visible = true
	skip_screencover.modulate.a = 1.0
	tween.attribute("modulate:a",0.0,.4,skip_screencover)

func stop_all_music_and_sounds():
	firenoise.stop()
	explosion_sfx.stop()
	lumine_theme.stop()
	vile_theme.fade_out(.5)

func turn_player_towards_boss() -> void:
	if not executing:
		return
	var player = GameManager.player
	if player.get_direction() != 1:
		if player.get_direction() != 0:
			GameManager.player.animatedSprite.play("recover")
		GameManager.player.set_direction(1)

func shake_door():
	if not executing:
		return
	var p = door.position.x
	var a = 3.0
	tween.attribute("position:x", p-a , 0.03,door)
	tween.add_attribute("position:x", p+a , 0.03,door)
	tween.add_attribute("position:x", p , 0.03,door)
	doorhit.play()
	doorhit.volume_db += 4
	doorhit.pitch_scale += .1

func shake_craft():
	if not executing:
		return
	var p = craft.position.x
	tween.attribute("position:x",p-1,0.05,craft)
	tween.add_attribute("position:x",p+1,0.05,craft)
	tween.add_attribute("position:x",p,0.05,craft)

func activate_door_smoke(value = true):
	if not executing:
		return
	door_smoke.emitting = value
	door_smoke_2.emitting = value

func kick_door():
	if not executing:
		return
	activate_door_smoke()
	Event.emit_signal("screenshake",2.0)
	explode.play()
	tween.attribute("position:x",-200,1.0,door)
	tween.create(Tween.EASE_OUT,Tween.TRANS_QUAD)
	tween.add_attribute("position:y",-90,0.4,door)
	tween.set_ease(Tween.EASE_IN,Tween.TRANS_QUAD)
	tween.add_attribute("position:y",90,0.6,door)
	tween.add_callback("activate_door_smoke",self,[false])
	
	tween.attribute("rotation_degrees",60,1.0,door)
	tween.method("blink_door",0,120,1.0)
	tween.add_callback("appear",sigma)
	tween.add_callback("hide_door")
	tween.add_wait(3)
	tween.add_callback("play",lumine_theme)
	tween.add_callback("spawn_sigmas")

func spawn_sigmas():
	if not executing:
		return
	sigma.move(-60)
	sigma.color_to_light()
	sigma2.appear_and_move(0.1,60)
	Tools.timer_p(2,"appear_and_move",sigma3,[.5,20])
	Tools.timer_p(3,"appear_and_move",sigma4,[.5,-20])
	Tools.timer(7.0,"start_next_dialog",self)

func start_next_dialog():
	if not executing:
		return
	match current_dialog:
		0:
			dialogbox.startup(dialog_1)
		1:
			dialogbox.startup(dialog_2)
		2:
			dialogbox.startup(dialog_3)
		3:
			dialogbox.startup(dialog_4)
	current_dialog += 1

func on_dialog_end():
	match current_dialog:
		1:
			Tools.timer(.5,"move_for_lumine",self)
		2:
			Tools.timer(.1,"transform_all_reploids",self)
		3:
			Tools.timer(.5,"prepare_for_explosion",self)
		4:
			Tools.timer(.5,"vile_leave",self)

func move_for_lumine():
	if not executing:
		return
	sigma.move(-30)
	sigma2.move(14)
	Tools.timer_p(.5,"move",sigma4,-30)
	Tools.timer_p(.5,"move",sigma3,14)
	Tools.timer(1,"appear",lumine)
	Tools.timer(3,"start_next_dialog",self)

func transform_all_reploids():
	if not executing:
		return
	lumine.color_to_light()
	sigma2.transform_into_reploid()
	lumine_theme.queue_ending()
	Tools.timer(.2,"transform_into_reploid",sigma)
	Tools.timer(.5,"transform_into_reploid",sigma3)
	Tools.timer(.7,"transform_into_reploid",sigma4)
	Tools.timer(4,"start_next_dialog",self)

func prepare_for_explosion():
	if not executing:
		return
	lumine_theme.fade_out(3)
	Event.emit_signal("screenshake",2.0)
	Tools.timer(1.8,"explode_everything",self)
	explosion_sfx.play()

func explode_everything():
	if not executing:
		return
	Event.emit_signal("screenshake",2.0)
	flash.start()
	explosion_particles.emitting = true
	wall_particles.emitting = true
	screencover.visible = true
	screencover.modulate.a = 0.0
	tween.attribute("modulate:a",1,1.0,screencover)
	tween.attribute("volume_db",-80,4.0,firenoise)
	tween.method("set_radius",26,120,1)
	Tools.timer(4.0,"stop_explosions",self)
	Tools.timer(5.0,"fade_flash",self)

func stop_explosions():
	if not executing:
		return
	background_cover.visible = false
	lumine.visible = false
	sigma.visible = false
	sigma2.visible = false
	sigma3.visible = false
	sigma4.visible = false
	visuals.visible = false
	craft.modulate = Color.darkgray
	Tools.timer_p(1.0,"set_deferred",explosion_particles,["emitting",false])
	
onready var dust: Particles2D = $dust

	
func fade_flash():
	if not executing:
		return
	dust.emitting = true
	tween.attribute("modulate:a",0,4.0,screencover)
	kidnapped.visible = true
	tween.add_callback("bring_vile")
	Event.emit_signal("screenshake",2.0)

func bring_vile():
	if not executing:
		return
	vile.visible = true
	traverse.play()
	Tools.timer(0.75,"play",vile_theme)
	dialogbox.rect_position.y += 35 + 4
	Tools.timer(1.0,"play",elec_thing)
	tween.create(Tween.EASE_OUT,Tween.TRANS_CUBIC)
	tween.add_attribute("position:y",vile.position.y + 80,1.5,vile)
	tween.add_callback("start_next_dialog")
	tween.create(Tween.EASE_IN_OUT,Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.add_attribute("position:y",kidnapped.position.y - 80,2.0,kidnapped)
	tween.add_attribute("position:x",kidnapped.position.x + 26,2.0,kidnapped)

func vile_leave():
	if not executing:
		return
	traverse.play()
	Tools.timer(.3,"play",elec_thing)
	tween.reset()
	vile.play("flight_to_upward")
	Tools.timer_p(.25,"play",vile,"upward")
	Tools.timer(.5,"move_player_a_bit_foward",self)
	tween.create(Tween.EASE_IN,Tween.TRANS_CUBIC)
	tween.add_attribute("position:y",vile.position.y - 80,1,vile)
	tween.create(Tween.EASE_IN,Tween.TRANS_CUBIC)
	tween.add_attribute("position:y",kidnapped.position.y - 80,1.5,kidnapped)
	tween.add_wait(1.0)
	tween.add_callback("finish_cutscene")
	#tween.add_callback("fade_out",vile_theme,[5])

func move_player_a_bit_foward():
	if not executing:
		return
	var player = GameManager.player
	player.play_animation("walk")
	tween.attribute("position:x",player.position.x + 67.5,.75,player)
	tween.add_callback("finished_player_movement")

func finished_player_movement():
	var player = GameManager.player
	player.play_animation("recover")

func finish_cutscene():
	if not executing:
		return
	vile.visible = false
	kidnapped.visible = false
	executing = false
	set_physics_process(false)
	Event.emit_signal("noahspark_cutscene_end")
	
func explode_craft():
	flash.start()
	Tools.timer(0.1,"hide_craft",self)
	craft_explosion.emitting = true
	remains_particles.emitting = true
	vile_theme.fade_out(.5)

func hide_craft():
	craft.visible = false

func reset():
	tween.reset()
	door.position = Vector2.ZERO
	door.rotation_degrees = 0.0
	door.self_modulate.a = 1.0
	sigma.reset()
	sigma2.reset()
	sigma3.reset()
	sigma4.reset()
	blink_light_forever()
	activate_door_smoke(false)

func hide_door():
	door.self_modulate.a = 0

func blink_door(value):
	blink(door,value)

func blink_light_forever():
	tween.method("blink_light",0,10,1.0)
	tween.add_callback("blink_light_forever")

func blink_light(value):
	light.self_modulate.a = inverse_lerp(-1,1,sin(value)) * 0.3 + 0.7

func blink(object, time : float):
	object.self_modulate.a = inverse_lerp(-1,1,sin(time))
	
func set_radius(value:float):
	explosion_particles.process_material.emission_sphere_radius = value
	
