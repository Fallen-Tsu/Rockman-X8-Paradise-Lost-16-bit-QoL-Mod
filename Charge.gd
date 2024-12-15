extends Ability
class_name Charge


export var super_charged_sound : AudioStream
var super_charge_time := 2
var maximum_charge_time := 5
export var color : Color
export var super_color : Color
var charged_time : float
var max_charge : bool
var mid_charge : bool
var charging := false


export var minimum_charge_time := 0.3
export var level_3_charge := 1.75
export var level_4_charge := 2.15

export var charge_time_reduction := 0.0

var current_weapon
onready var audio2 = $audioStreamPlayer2
onready var charge1_volume = $audioStreamPlayer.volume_db
onready var charge2_volume = $audioStreamPlayer2.volume_db

onready var charging_particle = character.get_node("animatedSprite").get_node("ChargingParticle")
onready var charged_particle = character.get_node("animatedSprite").get_node("ChargedParticle")
onready var super_particle = character.get_node("animatedSprite").get_node("SuperChargeParticle")

onready var particles = [charging_particle, charged_particle, super_particle]

onready var arm_cannon = character.get_node("Shot")

onready var tween := TweenController.new(self)
signal stop

func _ready() -> void:
# warning-ignore:return_value_discarded
	Event.listen("changed_weapon",self,"update_current_weapon")
	Event.listen("pause_menu_opened",self,"on_pause")
	Event.listen("pause_menu_closed",self,"on_unpause")
	audio = get_node("audioStreamPlayer")
	Tools.timer_p(.1,"set_deferred",self,["debug_logs",false])

func on_pause():
	if executing:
		audio.set_stream_paused(true) 
		audio2.set_stream_paused(true) 
		tween.pause()

func on_unpause():
	if executing:
		audio.set_stream_paused(false) 
		audio2.set_stream_paused(false) 
		tween.unpause()

	
func _Setup():
	setup_charge_fadeout()
	set_current_charge_button()

func setup_charge_fadeout() -> void:
	audio.volume_db = charge1_volume
	audio2.volume_db = charge2_volume
	if Configurations.get("ChargeFadeOut"): #change for config
		tween.create(Tween.EASE_IN_OUT,Tween.TRANS_LINEAR,true)
		tween.add_attribute("volume_db",-80.0,45.0,audio)
		tween.add_attribute("volume_db",-80.0,45.0,audio2)
		tween.set_ignore_pause_mode()

func _process(_delta: float) -> void:
	BANDAID_stop_audio_if_not_executing()

func BANDAID_stop_audio_if_not_executing():
	if audio.playing or audio2.playing:
		if not executing:
			stop_vfx()
			Log("Forcefully stopped undesired playing sound")

func _StartCondition() -> bool:
	if not current_weapon:
		update_current_weapon(arm_cannon.current_weapon)
	if current_weapon is BossWeapon and not arm_cannon.upgraded:
		return false
	if not character.is_executing("Ride") and not character.block_charging:
		if get_current_weapon_ammo() > 0 or arm_cannon.infinite_charged_ammo:
			if get_charge_pressed():
				return true
	return false

func _Update(_delta:float) -> void:
	if get_charge_released() and character.listening_to_inputs or get_charge_just_pressed() and character.listening_to_inputs:
		if charged_time > minimum_charge_time * (1 - charge_time_reduction):
			emit_fire_charged_signal(get_charge_level())
		else:
			EndAbility()
	elif get_charge_pressed():
		charge(_delta)
	else:
		if character.listening_to_inputs:
			EndAbility()

onready var charge_button = get_default_charge_button()

func get_default_charge_button() -> String:
	return "fire"

func get_charge_pressed() -> bool:
	return get_action_pressed(actions[0]) #or get_action_pressed(actions[1])

func set_current_charge_button() -> void:
	if get_action_pressed(actions[0]):
		charge_button = actions[0]
	elif get_action_pressed(actions[1]):
		charge_button = actions[1]

func get_charge_just_pressed() -> bool:
	return get_action_just_pressed(charge_button)

func get_charge_released() -> bool:
	return not get_action_pressed(charge_button)

func get_charge_level() -> int:
	if charged_time < minimum_charge_time * (1 - charge_time_reduction):
		return 0
	if charged_time < level_3_charge * (1 - charge_time_reduction):
		return 1
	if charged_time < level_4_charge * (1 - charge_time_reduction):
		return 2
	if charged_time > level_4_charge * (1 - charge_time_reduction):
		if arm_cannon.upgraded:
			return 3
		else:
			return 2
	return 0

func _EndCondition() -> bool:
	if charged_time == 0 and timer > 0.1:
		return true
	if charged_time < minimum_charge_time* (1 - charge_time_reduction) and not get_charge_pressed():
		return true
	if character.is_executing("Ride"):
		return true
	return false
	
func charge(_delta:float):
	if charged_time < maximum_charge_time:
		charged_time += _delta
	if charged_time > minimum_charge_time * (1 - charge_time_reduction):
		if not charging:
			start_vfx()
	if get_charge_level() > 1:
		if not mid_charge:
				emit_charged_particle()
				mid_charge = true
	if not max_charge:
		if super_charge_time > 0 and charged_time > level_4_charge * (1 - charge_time_reduction):
			if arm_cannon.upgraded:
				Log("Started super VFX")
				max_charge = true
				change_color(super_color)
				emit_supercharge_particle()
				play_super_sound()
	
func emit_fire_charged_signal(_charged_time):
	if character.listening_to_inputs: #prevents firing during cutscenes
		Log("Shot Release")
		Event.emit_signal("charged_shot_release", _charged_time)
	EndAbility()

func start_vfx():
	Log("Started VFX")
	play_sound(sound, false)
	emit_charging_particle()
	enable_charge_shader()
	change_color(color)
	charging = true

func stop_vfx():
	stop_sound()
	stop_emission()
	disable_charge_shader()
	change_color(color)
	charging = false
	mid_charge = false
	max_charge = false
	Log("Stopped VFX")

func play_super_sound():
	audio2.stream = super_charged_sound
	audio2.play()

func stop_sound():
	.stop_sound()
	audio2.stop()

func emit_charging_particle():
	for particle in particles:
		particle.visible = false
	charging_particle.visible = true
	
func emit_charged_particle():
	for particle in particles:
		particle.visible = false
	charged_particle.visible = true
	
func emit_supercharge_particle():
	for particle in particles:
		particle.visible = false
	super_particle.visible = true
	
func stop_emission():
	for particle in particles:
		particle.visible = false

func change_color(_color):
	character.animatedSprite.material.set_shader_param("Color", _color)
	
func enable_charge_shader():
	character.animatedSprite.material.set_shader_param("Charge", 1)

func disable_charge_shader():
	character.get_node("animatedSprite").material.set_shader_param("Charge", 0)

func _Interrupt():
	charged_time = 0
	stop_vfx()
	emit_signal("stop")

func get_current_weapon_ammo() -> float:
	if not current_weapon:
		update_current_weapon()
		return 0.0
	return current_weapon.get_ammo()

func update_current_weapon(_new_weapon = null):
	if arm_cannon.current_weapon:
		current_weapon = arm_cannon.current_weapon

func play_sound_on_initialize() -> void:
		pass
		
func should_execute_on_hold() -> bool:
	return true

func should_always_listen_to_inputs() -> bool:
	return true
