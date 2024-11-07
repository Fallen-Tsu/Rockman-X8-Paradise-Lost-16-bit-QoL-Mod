extends Node

export var section := "section_name"

var running := true
	
var time_elapsed = 0.0

func _ready() -> void:
	Event.connect("beat_seraph_lumine",self,"stop")
	running = true

func _physics_process(delta: float) -> void:
	if running:
		IGT.add(section,delta)
		time_elapsed += delta
		if time_elapsed >= 1:
			IGT.send_command("set_gametime_command")
			time_elapsed = 0.0

func stop() -> void:
	var final_time = 0.0
	for section_name in IGT.times:
		final_time += IGT.times[section_name]
	IGT.total_time = final_time
	IGT.send_command("set_gametime_command")
	IGT.send_command("split_command")
	running = false
