extends StreamPeerTCP
class_name LiveSplitTCPClient

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _status: int = 0
signal connected_to_livesplit
# Called when the node enters the scene tree for the first time.
func setup():
	_status = get_status()

func _process(_delta: float) -> void:
	var new_status: int = get_status()
	if new_status != _status:
		_status = new_status
		match _status:
			STATUS_NONE:
				print("Disconnected from host.")
			STATUS_CONNECTING:
				print("Connecting to host.")
			STATUS_CONNECTED:
				emit_signal("connected_to_livesplit")
				set_no_delay(true)
				print("Connected to host.")
			STATUS_ERROR:
				print("Error with socket stream.")

	if _status == STATUS_CONNECTED:
		var available_bytes: int = get_available_bytes()
		if available_bytes > 0:
			print("available bytes: ", available_bytes)
			var data: Array = get_partial_data(available_bytes)
			# Check for read error.
			if data[0] != OK:
				push_error("Error getting data from stream: " + data[0])
			else:
				print("Data received: ", data[1])
	if _status == STATUS_NONE or _status == STATUS_ERROR:
		var ip = "127.0.0.1"
		var port: int = 16834
		if Configurations.get("SplitIP"):
			ip = Configurations.get("SplitIP")
		if Configurations.get("SplitPort"):
			port = int(Configurations.get("SplitPort"))
		var err = connect_to_host(ip, port)
		if err != OK:
			push_error("Error connecting to host: " + err)
		else:
			set_no_delay(true)
			emit_signal("connected_to_livesplit")
		

func send_command(command: String):
	if get_status() == StreamPeerTCP.STATUS_CONNECTED:
		print("Sending command: " + command)
		var packet: PoolByteArray = call(command)
		print(packet.get_string_from_utf8())
		var err = put_data(packet)
		if err != OK:
			push_error("Error writing to stream: " + err)

func stop():
	disconnect_from_host()

func start_run():
	send_command("split_command")
	send_command("pause_igt_command")

func split_command():
	return "startorsplit\n".to_utf8()

func reset_command():
	return "reset\n".to_utf8()

func pause_igt_command():
	return "alwayspausegametime\n".to_utf8()
	
func set_gametime_command():
	var time = Tools.get_full_readable_time(IGT.total_time)
	var msg = "setgametime " + time + "\n"
	return msg.to_utf8()

func has_peer_connected():
	return get_status() == STATUS_CONNECTED
