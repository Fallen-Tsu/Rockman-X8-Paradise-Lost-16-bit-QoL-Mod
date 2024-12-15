extends EnemyDeath
class_name BossDeath

export var freeze_time := 1.0
var freeze_moment := 0.0
var freeze_over := false
export var explosion_time := 3.0
export var death_animation := "death"
export var pause_animation := true
export var force_reploid_death := false
export var collectible := "boss_weapon"
export var defeated_flag := "none"
var explosion_over := false
var background_alpha := 0.0 
var elapsed_explosion_time := 0.0
var elapsed_alpha_time := 0.0
var elapsed_color_time := 0.0
var tempo := 0 
var darken := 1.0
var sprite_alpha := 1.0
var total_alpha := 1.0
var sub_alpha := 1.0
var sub_speed := 1.0
var delta := 0.016

onready var smoke = $"Smoke Particles"
onready var background = get_node("background_light")
onready var touch_damage = get_parent().get_node("DamageOnTouch")
onready var reploid: AnimatedSprite = $reploid
onready var transform_audio: AudioStreamPlayer2D = $reploid/transform

signal screen_flash

func _ready() -> void:
	reploid.material = sprite.material
	set_background_alpha(0)
	set_background_color(0)

func _Setup():
	character.set_horizontal_speed(0)
	character.set_vertical_speed(0)
	animate_boss_or_reploid()
	Event.emit_signal("enemy_kill","boss")
	GameManager.start_end_cutscene()
	character.emit_signal("death")
	if pause_animation:
		sprite.playing = false
	else:
		sprite.pause_mode = Node.PAUSE_MODE_PROCESS
		pass
	touch_damage.active = false
	elapsed_explosion_time = 0.0
	background.scale.x = 100
	background.scale.y = 40 
	GameManager.pause(character.name + name)
	freeze_moment = OS.get_ticks_msec()
	IGT.calculate_total_time()
	if IGT.has_peer():
		if Configurations.get("SplitOnBossKill"):
			IGT.send_command("set_gametime_command")
			IGT.send_command("split_command")
		else:
			var seconds := 15.0 if collectible == "finished_intro" else 17.0
			Tools.timer_p(seconds,"send_command",IGT,"set_gametime_command")
			Tools.timer_p(seconds,"send_command",IGT,"split_command")

func animate_boss_or_reploid() -> void:
	if death_animation != "":
		character.play_animation(death_animation)
	if force_reploid_death or collectible in GameManager.collectibles:
		reploid.visible = true
		reploid.playing = true
		reploid.scale.x = sprite.scale.x
		character.animatedSprite.visible = false
		transform_audio.play()

func _physics_process(_delta: float) -> void:
	if executing:
		if is_freeze_time_over() and freeze_over == false:
			GameManager.unpause(character.name + name)
			smoke.emitting = true
			explosions.emitting = true
			$audioStreamPlayer2D.play()
			freeze_over = true
			tempo = 1

var emitted_fading_signal := false

signal start_fade

func _Update(_delta: float):
	delta = _delta
	
	if tempo > 0:
		elapsed_explosion_time += _delta
		
	if tempo == 1:
		set_background_alpha(tween_alpha(.75,5))
	
	if tempo == 2:
		tempo_change()
	if tempo == 3:
		darken -= _delta/8
		sprite.material.set_shader_param("Darken", darken)
		set_background_color(tween_color(1,7))

	if tempo == 4:
		tempo_change()
	if tempo == 5:
		set_background_color(tween_color(2))
		set_background_alpha(tween_alpha(1))
		darken -= _delta/2
		sprite.material.set_shader_param("Darken", darken)
		
	if tempo == 6:
		if not emitted_fading_signal:
			emit_signal("start_fade")
			emitted_fading_signal = true
			background_alpha = 1
			
		sprite_alpha -= _delta/4.5
		sprite.material.set_shader_param("Alpha", sprite_alpha)
		
	if sprite.material.get_shader_param("Alpha") <= 0.35:
		smoke.emitting = false
	
	
	if is_explosion_time_over():
		emit_flash_signals()
		end_explosion(_delta)

func end_explosion(_delta):
	background.scale.x = 400
	background.scale.y = 160 
	explosions.emitting = false
	sprite.visible = false
	reploid.visible = false
	background_alpha -= _delta/1.7
	set_background_alpha(background_alpha)
	

var emitted_flash := false
func emit_flash_signals():
	if not emitted_flash:
		emitted_flash = true
		Event.emit_signal("boss_death_screen_flash")
		emit_signal("screen_flash")

func tween_alpha(max_alpha:float, speed:= 1) -> float:
	elapsed_alpha_time += delta * speed
	var alpha = elapsed_alpha_time/explosion_time
	if alpha > max_alpha:
		tempo += 1
		Log("tempo up: " + str(tempo))
		return max_alpha
	return alpha

func tween_color(max_color:float, speed:= 1) -> float:
	elapsed_color_time += delta * speed
	var color = elapsed_color_time/explosion_time 
	if color > max_color:
		tempo += 1
		Log("tempo up: " + str(tempo))
		emit_signal("changed_stage",tempo)
		return max_color
	return color

signal changed_stage(stage)

func tempo_change():
	if elapsed_explosion_time > (explosion_time * tempo)/9:
		tempo += 1
		Log("tempo up: " + str(tempo))
		emit_signal("changed_stage",tempo)
		
func set_background_color(value : float):
	background.material.set_shader_param("Color",value)
	
func set_background_alpha(value : float):
	var alpha = value
	if alpha > 1:
		alpha = 1
	if alpha < 0:
		alpha = 0
	background_alpha = alpha
	background.material.set_shader_param("Alpha",background_alpha)

func is_explosion_time_over() -> bool:
	return freeze_over and elapsed_explosion_time > explosion_time
	
func during_explosion_time() -> bool:
	return elapsed_explosion_time < explosion_time

func is_freeze_time_over() -> bool:
	if OS.get_ticks_msec() > freeze_time * 1000 + freeze_moment:
		return true
	return false

func _Interrupt():
	GameManager.end_boss_death_cutscene()
	BossRNG.boss_defeated(character.name)
	elapsed_explosion_time = 0.0
	elapsed_alpha_time = 0.0
	elapsed_color_time = 0.0
	tempo = 0
	darken = 1
	sprite_alpha = 1
	freeze_over = false
	explosion_over = false
	add_weapon_to_savedata()
	if defeated_flag != "none":
		GlobalVariables.add(defeated_flag,"defeated")
	get_parent().queue_free()

func add_weapon_to_savedata():
	if collectible != "boss_weapon":
		if not GameManager.is_collectible_in_savedata(collectible):
			GameManager.add_collectible_to_savedata(collectible)
			if "weapon" in collectible:
				GameManager.prepare_weapon_get(collectible, GameManager.player.current_armor)
	

func _StartCondition() -> bool:
	return false

func _EndCondition() -> bool:
	return elapsed_explosion_time >= explosion_time + 3.12 and background_alpha <= 0

func emit_remains_particles():
	pass
