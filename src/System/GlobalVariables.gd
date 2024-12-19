extends Node

signal value_changed(key)
var debug := false
var used_cheat_code: bool = false 
var variables := {}

func set(key,value) -> void:
	debug_log("Setting " + key + " to " + str(value))
	variables[key] = value
	emit_signal("value_changed",key)

func add(key,value) -> void:
	if not exists(key):
		variables[key] = value
	else:
		variables[key] += value
	emit_signal("value_changed",key)

func erase(key) -> void:
	if exists(key):
		variables.erase(key)

func get(key):
	#print("GlobalVariables: Trying to get key: " + key)
	if exists(key):
		return variables[key]
	return null

func exists(key) -> bool:
	return key in variables

func listen(event_name : String, listener, method_to_call : String):
	var error_code = connect(event_name,listener,method_to_call)
	if error_code != 0:
		print_debug ("GlobalVariables: Connection error. Code: " + str(error_code))
		print_debug (listener.name + "'s method "+ method_to_call + " on event " + event_name)

func load_variables(new_variables) -> void:
	if new_variables:
		for key in new_variables.keys():
			variables[key] = new_variables[key]
		for key in variables.keys():
			emit_signal("value_changed",key)
	else:
		variables.clear()
		push_warning("No Loading. Variables: " + str(new_variables))

func debug_log (message) -> void:
	if debug:
		print_debug ("GlobalVariables: " + str(message))
