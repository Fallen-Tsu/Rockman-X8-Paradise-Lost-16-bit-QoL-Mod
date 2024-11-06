extends X8TextureButton

export var pick_sound : NodePath

func on_press() -> void:
	if IGT.has_peer():
		IGT.start_run()
	get_node(pick_sound).play()
	Event.emit_signal("fadeout_startmenu")
	strong_flash()
	menu.lock_buttons()
	menu.fader.SoftFadeOut()
	yield(menu.fader,"finished")
	GameManager.seen_dialogues.clear()
	go_to_next_scene() 
	
func go_to_next_scene() -> void:
	IGT.reset()
	if already_finished_noahs_park():
		GameManager.call_deferred("go_to_stage_select")
	else:
		GameManager.start_level("NoahsPark")

func already_finished_noahs_park() -> bool:
	return "finished_intro" in GameManager.collectibles
