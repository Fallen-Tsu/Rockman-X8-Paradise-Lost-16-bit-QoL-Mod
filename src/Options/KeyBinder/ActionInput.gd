extends LightGroup

onready var action_name: Label = $actionname
onready var key: = $key
onready var joypad := $joypad
var action
var readname

func _ready():
	Event.connect("translation_updated",self,"update_action_name")

func setup(_action, _readname, menu) -> void:
	key.connect_lock_signals(menu)
	joypad.connect_lock_signals(menu)
	action = _action
	readname = _readname
	update_action_name()
	var _s = key.connect("updated_event",self,"get_inputs_and_set_names")
	_s = joypad.connect("updated_event",self,"get_inputs_and_set_names")
	
	get_inputs_and_set_names(action)

func update_action_name():
	action_name.text = tr(readname)
	
func set_button_and_text(button, _action = action, prev_keyboard: = false, prev_joypad: = false) -> Array:
	var named_keyboard := false or prev_keyboard
	var named_joypad := false or prev_joypad
	if button is InputEventJoypadButton and not named_joypad:
		joypad.set_text(Input.get_joy_button_string(button.button_index))
		joypad.original_event = button
		named_joypad = true
	elif button is InputEventJoypadMotion and not named_joypad:
		joypad.set_text(Input.get_joy_axis_string(button.axis))
		joypad.original_event = button
		named_joypad = true
	if button is InputEventKey and not named_keyboard:
		key.set_text(button.as_text())
		key.original_event = button
		named_keyboard = true
	elif button is InputEventMouseButton and not named_keyboard:
		key.set_text ( "Mouse" + str(button.button_index))
		key.original_event = button
		named_keyboard = true
	return [named_keyboard, named_joypad]

func get_inputs_and_set_names(_action = action) -> void:
	var inputs = InputMap.get_action_list(_action)
	for button in inputs:
		# warning-ignore:return_value_discarded
		set_button_and_text(button, _action)

func get_inputs_and_set_names_after_reset(_action = action) -> void:
	var inputs = InputMap.get_action_list(_action)
	var named_keyboard := false
	var named_joypad := false
	for button in inputs:
		var named_values = set_button_and_text(button, _action, named_keyboard, named_joypad)
		named_keyboard = named_values[0]
		named_joypad = named_values[1]
		
	if not named_joypad:
		joypad.set_text("INPUT_UNASSIGNED")
	if not named_keyboard:
		key.set_text("INPUT_UNASSIGNED")
