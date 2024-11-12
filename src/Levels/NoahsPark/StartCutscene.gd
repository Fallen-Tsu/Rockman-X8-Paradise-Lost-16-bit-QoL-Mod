extends Node

export var dialogue : Resource
var started := false
func _ready() -> void:
	Tools.timer(3,"start",self)

func start():
	if Configurations.get("AutoSkipDialog"):
		start_gameplay()
	elif not GameManager.was_dialogue_seen(dialogue):
		GameManager.start_dialog(dialogue)
	else:
		start_gameplay()

func start_gameplay():
	started = true
	print("Starting Gameplay.........................")
	GameManager.player.activate()
	Event.emit_signal("gameplay_start")
	GameManager.player.reactivate_charge()


func _on_dialog_concluded() -> void:
	if not started:
		start_gameplay()
