extends Node

const sections := 13

var active_connection = null

var already_started: bool = false

var times := {}

var total_time: float = 0.0
var current_section: String = "Misc."

signal connection_timeout
signal connection_established

var connection_timeout: Timer = Timer.new()

func _ready():
	pass

func reset():
	already_started = false
	times.clear()
	total_time = 0.0

func add(section_name,delta):
	if section_name in times:
		times[section_name] += delta
	else:
		times[section_name] = 0.0
	total_time += delta
	current_section = section_name

func calculate_total_time():
	var sum = 0.0
	for section_name in times:
		sum += times[section_name]
	total_time = sum

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if active_connection:
			active_connection.stop()
			

func _process(delta):
	if active_connection:
		active_connection._process(delta)
		if not active_connection.has_peer_connected() and connection_timeout.is_stopped():
			connection_timeout = Tools.timer_r(5.0, "close_connection", self)
		else:
			connection_timeout.stop()

func clocked_all_stages() -> bool:
	return times.size() == sections

func initialize_connection():
	if active_connection:
		active_connection.disconnect("connected_to_livesplit",self,"_on_connected_to_livesplit")
	if Configurations.get("SplitType"):
		active_connection = LiveSplitOneWebSocket.new()
	else:
		active_connection = LiveSplitTCPClient.new()
	active_connection.connect("connected_to_livesplit",self,"_on_connected_to_livesplit")
	active_connection.setup()

func close_connection(_stub = null):
	if active_connection:
		active_connection.stop()
		active_connection = null
		emit_signal("connection_timeout")

func send_command(command: String):
	if active_connection:
		active_connection.send_command(command)
		if command == "reset_command":
			already_started = false

func start_run():
	if not already_started:
		already_started = true
		send_command("split_command")
		send_command("pause_igt_command")



func has_peer() -> bool:
	if active_connection:
		return active_connection.has_peer_connected()
	else:
		return false

func connection_exists() -> bool:
	return not active_connection == null

func _on_connected_to_livesplit():
	emit_signal("connection_established")
