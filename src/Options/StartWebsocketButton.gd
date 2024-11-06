extends X8OptionButton


func setup() -> void:
	set_server_status(query_websocket_state())

func increase_value() -> void: #override
	set_server_status(!query_websocket_state())

func decrease_value() -> void: #override
	set_server_status(!query_websocket_state())

func set_server_status(value:bool) -> void:
	if value:
		if not query_websocket_state():
			IGT.initialize_websocket_server()
	else:
		IGT.close_websocket_server()
	display_server_status()

func query_websocket_state() -> bool:
	return IGT.websocket_server.is_listening()

func display_server_status():
	if query_websocket_state():
		display_value("SERVER_ON")
	else:
		display_value("SERVER_OFF")
