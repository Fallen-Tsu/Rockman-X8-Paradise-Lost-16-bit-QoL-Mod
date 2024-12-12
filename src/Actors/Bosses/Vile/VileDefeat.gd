extends AttackAbility
onready var explosion: AudioStreamPlayer2D = $explosion
onready var explosion_particles: Particles2D = $explosion_particles
onready var beam_out: AudioStreamPlayer2D = $beam_out
onready var sparks: AudioStreamPlayer2D = $sparks

export var defeat_flag := "none"
signal screen_flash

func _ready() -> void:
	character.listen("zero_health",self,"start")

func start() -> void:
	character.interrupt_all_moves()
	IGT.calculate_total_time()
	if defeat_flag == "vile3_defeated" and IGT.has_peer():
		if Configurations.get("SplitOnBossKill"):
			IGT.send_command("set_gametime_command")
			IGT.send_command("split_command")
		else:
			IGT.can_split = true
	ExecuteOnce()

func _Setup() -> void:
	play_animation("defeat_fall")
	call_deferred("force_movement_regardless_of_direction", horizontal_velocity * -get_player_direction_relative())
	set_vertical_speed(-jump_velocity)
	explosion_particles.emitting = true
	explosion.play()
	emit_signals()

func emit_signals() -> void:
	character.emit_signal("death")
	Event.emit_signal("enemy_kill",character)
	GameManager.start_cutscene()
	GameManager.player.stop_charge()
	Tools.timer(0.5,"unfreeze",self,null,true)
	GameManager.pause("VileDefeat")
	Event.emit_signal("vile_defeated")

func _Update(delta) -> void:
	process_gravity(delta)
	if attack_stage == 0 and timer > 0.1:
		explosion_particles.emitting = false
		if character.is_on_floor():
			turn_and_face_player()
			play_animation("defeat_land")
			force_movement(0)
			next_attack_stage()
	
	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("defeat")
		sparks.play()
		next_attack_stage()
	
	elif attack_stage == 2 and timer > 1.75:
		play_animation("beam_out")
		beam_out.play()
		sparks.stop()
		next_attack_stage()

	elif attack_stage == 3 and has_finished_last_animation():
		animatedSprite.position.y -= 480 * delta
		if defeat_flag == "none":
			if timer > 0.85:
				GameManager.end_cutscene()
				Event.emit_signal("play_stage_song")
				next_attack_stage()
				Event.emit_signal("boss_health_hide")
				emit_signal("screen_flash")
				character.destroy()
					
		elif timer > 1.55:
			GlobalVariables.set(defeat_flag,"defeated")
			GameManager.end_boss_death_cutscene()
			next_attack_stage()
			emit_signal("screen_flash")
			character.destroy()

func _Interrupt() -> void:
	push_error("Interrupted Vile's Death")

func unfreeze() -> void:
	GameManager.unpause("VileDefeat")
	
