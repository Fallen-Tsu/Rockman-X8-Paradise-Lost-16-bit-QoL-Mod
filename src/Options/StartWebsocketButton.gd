extends X8OptionButton

func setup() -> void:
	if not IGT.is_connected("connection_established",self,"display_with_sound"):
		IGT.connect("connection_established",self,"display_with_sound")
	if not IGT.is_connected("connection_timeout",self,"display_with_sound"):
		IGT.connect("connection_timeout",self,"display_with_sound")
	display_server_status()

func increase_value() -> void: #override
	set_server_status(!IGT.connection_exists())

func decrease_value() -> void: #override
	set_server_status(!IGT.connection_exists())

func set_server_status(value:bool) -> void:
	if value:
		if IGT.connection_exists():
			IGT.close_connection()
		IGT.initialize_connection()
	else:
		if IGT.connection_exists():
			IGT.close_connection()
	display_server_status()

func display_with_sound():
	play_sound()
	display_server_status()
	strong_flash()

func display_server_status():
	if IGT.connection_exists() and IGT.has_peer():
		display_value("SERVER_ON")
	elif IGT.connection_exists() and not IGT.has_peer():
		display_value("SERVER_WAIT")
	else:
		display_value("SERVER_OFF")
