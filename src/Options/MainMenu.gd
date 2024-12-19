extends X8Menu

onready var info: Label = $Menu/demo_02
onready var cheat_sfx: AudioStreamPlayer = $CheatSfx

var last_inputs: Array = []  # Buffer to store recent inputs
var cheat_code: Array = ["move_left", "move_left", "move_left", 
						 "move_right", "move_right", "move_right", 
						 "move_left", "move_left", "move_left", "move_left", 
						 "move_right", "move_right", "move_right", "move_right"]

func _input(event: InputEvent) -> void:
	var full_cheat_code = false
	if not locked:
		if event.is_action_pressed("pause"):
			var start_event = InputEventAction.new()
			start_event.action = "ui_accept"
			start_event.pressed = true
			Input.parse_input_event(start_event)
	if not event is InputEventMouse and event.is_pressed():
		last_inputs.push_back(event)
	if last_inputs.size() > cheat_code.size():
			last_inputs.pop_front()
	if last_inputs.size() == cheat_code.size():
		for i in range(last_inputs.size()):
			if last_inputs[i].is_action(cheat_code[i]):
				full_cheat_code = true
			else:
				full_cheat_code = false
				break
	if full_cheat_code and not GameManager.used_cheat_code: 
		GameManager.used_cheat_code = true
		cheat_sfx.play()
	if not locked:
		if event.is_action_pressed("pause"):
			var start_event = InputEventAction.new()
			start_event.action = "ui_accept"
			start_event.pressed = true
			Input.parse_input_event(start_event) 

func _ready() -> void:
	info.text = GameManager.current_demo + " V." + GameManager.version
	print("Ready! Cheat code:", cheat_code)  # Debug: Print the cheat code for reference
