extends WebSocketServer
class_name LiveSplitOneWebSocket

var remote_peer_id: int = -1

signal connected_to_livesplit
# Called when the node enters the scene tree for the first time.
func setup():
	connect("client_connected",self,"_on_client_connected")
	connect("data_received",self,"_on_data_received")
	initialize_socket()

func initialize_socket():
	var port:int = 16834
	if Configurations.get("SplitPort"):
		port = int(Configurations.get("SplitPort"))
	set_bind_ip("0.0.0.0")
	var err = listen(port)
	if err != OK:
		push_error("Error initializing WebSocketServer: " + str(err))

func send_command(command: String):
	if has_peer(remote_peer_id):
		print("Sending command: " + command)
		var remote_peer = self.get_peer(remote_peer_id)
		remote_peer.set_no_delay(true)
		remote_peer.set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
		var packet: PoolByteArray = call(command)
		print(packet.get_string_from_utf8())
		remote_peer.put_packet(packet)

func start_run():
	send_command("split_command")
	send_command("pause_igt_command")

func _process(_delta):
	# Call this in _process or _physics_process.
	# Data transfer, and signals emission will only happen when calling this function.
	poll()
	
func split_command():
	return JSON.print({"command": "splitOrStart"}).to_utf8()

func reset_command():
	return JSON.print({"command": "reset"}).to_utf8()

func pause_igt_command():
	return JSON.print({"command": "pauseGameTime"}).to_utf8()
	
func set_gametime_command():
	var time_str = Tools.get_full_readable_time(IGT.total_time)
	return JSON.print({"command": "setGameTime", "time": time_str}).to_utf8()

func has_peer_connected():
	return has_peer(remote_peer_id)

func _on_client_connected(id: int, protocol: String):
	print("Client connected with id " + str(id) + " and protocol \"" + protocol + "\"")
	remote_peer_id = id
	emit_signal("connected_to_livesplit")
	
func _on_data_received(id: int):
	var message = self.get_peer(id).get_packet().get_string_from_utf8()
	print("Received message: " + message)
