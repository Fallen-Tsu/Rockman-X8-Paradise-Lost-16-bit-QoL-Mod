class_name ConfirmButton extends X8TextureButton
export var default_label := "CLEARSAVE_OPTION"
export var confirmation := "CLEARSAVE_CONFIRM"
var times_pressed := 0
var flashed = false
onready var text: Label = $text

func _ready() -> void:
	text.text = default_label
	Event.connect("translation_updated",self,"on_update")

func on_update():
	text.text = tr(default_label)
	pass

func on_press() -> void:
	times_pressed += 1
	if times_pressed == 1:
		if not flashed:
			strong_flash()
			flashed = true
		text.text = confirmation
	if times_pressed >= 2:
		strong_flash()
		yield(get_tree().create_timer(0.1),"timeout")
		action()

func action() -> void:
	#Savefile.clear_game_data()
	print("Deleting save...")
	GatewayManager.reset_bosses()
	GameManager.collectibles = []
	GlobalVariables.variables = {}
	IGT.reset()
	IGT.send_command("reset_command")
	#GameManager.rng.seed = 0000000000
	Savefile.save()
	GameManager.go_to_intro()
	GameManager._ready()
	

func _on_focus_exited() -> void:
	._on_focus_exited()
	flashed = false
	times_pressed = 0
	text.text = tr(default_label)
