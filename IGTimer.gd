extends Node

export var section := "section_name"

var running := true

func _exit_tree():
	if IGT.has_peer():
		IGT.send_command("pause_igt_command")
	
		

func _ready() -> void:
	Event.connect("beat_seraph_lumine",self,"stop")
	running = true
	call_deferred("resume_igt")

func resume_igt():
	if IGT.has_peer():
		IGT.send_command("resume_igt_command")

func _physics_process(delta: float) -> void:
	if running:
		IGT.add(section,delta)

func stop() -> void:
	IGT.send_command("split_command")
	running = false
