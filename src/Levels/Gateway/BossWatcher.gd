extends Node2D

var final_section_intro : AudioStream
var final_section_loop : AudioStream
export var final_section_intro_og : AudioStream
export var final_section_loop_og : AudioStream
export var final_section_intro_alt : AudioStream
export var final_section_loop_alt : AudioStream

var beaten_bosses : Array
var crystals_ready : Array
var sprites : Array

signal ready_for_battle
signal prepare_for_sigma
onready var ready_effect: Sprite = $"../charge_circle2"

func _ready() -> void:
	if Configurations.get("AltMusic"):
		final_section_intro = final_section_intro_alt
		final_section_loop = final_section_loop_alt
	else:
		final_section_intro = final_section_intro_og
		final_section_loop = final_section_loop_og
	Event.connect("gateway_crystal_get",self,"on_crystal_got")
	Event.connect("gateway_boss_defeated",self,"on_boss_defeated")
	Event.connect("gateway_final_section",self,"start_final_section")
	Tools.timer(0.1,"update_based_on_savedata",self)
	
	for child in get_children():
		if child is AnimatedSprite:
			sprites.append(child)
			child.visible = false
	
func update_based_on_savedata() -> void:
	if Configurations.get("GatewaySkip"):
		GatewayManager.beaten_bosses = ["antonion","panda","sunflower","mantis","manowar","trilobyte","yeti","rooster"]
	for boss in GatewayManager.beaten_bosses:
		print("Boss defeated: " + boss)
		Event.emit_signal("gateway_boss_defeated",boss)
	
	if has_defeated_all_bosses():
		GameManager.music_player.start_slow_fade_out()
		Tools.timer(2,"start_final_section",self)

func on_boss_defeated(boss_name) -> void:
	if not boss_name in beaten_bosses:
		beaten_bosses.append(boss_name)
	
	remove_ready_crystal(boss_name)
	if crystals_ready.size() < 2:
		Event.emit_signal("gateway_unlock_capsules")
	
func add_ready_crystal(boss_name) -> void:
	crystals_ready.append(boss_name)
	for sprite in sprites:
		if not sprite.visible:
			sprite.visible = true
			sprite.play(boss_name)
			break
	
func remove_ready_crystal(boss_name) -> void:
	crystals_ready.erase(boss_name)
	for sprite in sprites:
		if sprite.animation == boss_name:
			sprite.visible = false
			break
	
func on_crystal_got(boss_name) -> void:
	if not boss_name in crystals_ready:
		add_ready_crystal(boss_name)
	
	if has_enough_crystals():
		Event.emit_signal("gateway_lock_capsules")
		Tools.timer(0.5,"activate",ready_effect)
		emit_signal("ready_for_battle")

func has_enough_crystals() -> bool:
	if has_one_boss_left():
		return crystals_ready.size() >= 1
	else:
		return crystals_ready.size() >= 2

func has_one_boss_left() -> bool:
	return beaten_bosses.size() == 7

func has_defeated_all_bosses() -> bool:
	return beaten_bosses.size() == 8

func play_battle_song() -> void:
	GameManager.music_player.reset_fade_out()
	GameManager.music_player.play_angry_boss_song()

func _on_Door_open() -> void:
	if has_enough_crystals():
		GameManager.music_player.start_slow_fade_out()
	ready_effect.deactivate()

func _on_Door_finish() -> void:
	pass # Replace with function body.


func _on_bosses_defeated() -> void:
	GameManager.music_player.start_slow_fade_out()
	print("All bosses in boss room defeated. Total beaten:")
	print(beaten_bosses.size())
	if not has_defeated_all_bosses():
		print("heading to normal music")
		Tools.timer(6,"restart_stage_music",self)
	else:
		print("heading to final music")
		Tools.timer(6,"start_final_section",self)
		BossRNG.all_gateway_bosses_defeated()
	
func restart_stage_music():
		GameManager.music_player.play_stage_song_regardless_of_volume()
		GameManager.music_player.start_fade_in()
	

func _on_Door_closing_freeway() -> void:
	pass

func start_final_section() -> void:
	GameManager.music_player.play_song_wo_fadein(final_section_loop,final_section_intro)
	emit_signal("prepare_for_sigma")


func _on_Door_close() -> void:
	print("On Doof Finish")
	Tools.timer(4.7,"play_battle_song",self)
