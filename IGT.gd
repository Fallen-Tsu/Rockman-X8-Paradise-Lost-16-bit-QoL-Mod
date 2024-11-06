extends Node

const sections := 13

## TODO: Create a TCP client for og livesplit
onready var websocket_server: WebSocketServer = WebSocketServer.new()

var remote_peer_id: int = -1

var already_started: bool = false

var times := {}

func _ready():
	websocket_server.connect("client_connected",self,"_on_client_connected")
	websocket_server.connect("data_received",self,"_on_data_received")

func _process(_delta):
	# Call this in _process or _physics_process.
	# Data transfer, and signals emission will only happen when calling this function.
	websocket_server.poll()

func reset():
	already_started = false
	times.clear()

func add(section_name,delta):
	if section_name in times:
		times[section_name] += delta
	else:
		times[section_name] = 0.0

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if websocket_server.is_listening():
			websocket_server.stop()
			

func clocked_all_stages() -> bool:
	return times.size() == sections

func initialize_websocket_server():
	close_websocket_server()
	var port: int = int(Configurations.get("SplitPort"))
	websocket_server.set_bind_ip("0.0.0.0")
	var err = websocket_server.listen(port)
	if err != OK:
		push_error("Error initializing WebSocketServer: " + str(err))

func close_websocket_server():
	if websocket_server.is_listening():
		websocket_server.stop()
		websocket_server.disconnect("client_connected",self,"_on_client_connected")
		websocket_server.disconnect("data_received",self,"_on_data_received")
		websocket_server = WebSocketServer.new()
		websocket_server.connect("client_connected",self,"_on_client_connected")
		websocket_server.connect("data_received",self,"_on_data_received")

func send_command(command: String):
	if websocket_server.has_peer(remote_peer_id):
		print("Sending command: " + command)
		var remote_peer = websocket_server.get_peer(remote_peer_id)
		remote_peer.set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
		var packet: PoolByteArray = self.call(command)
		print(packet.get_string_from_utf8())
		remote_peer.put_packet(packet)

func start_run():
	if not already_started:
		already_started = true
		send_command("split_command")
		send_command("pause_igt_command")

func split_command():
	var packet: PoolByteArray
	if Configurations.get("SplitType"):
		packet = JSON.print({"command": "splitOrStart"},"\t" ).to_utf8()
	else:
		packet = "startorsplit".to_utf8()
	return packet

func reset_command():
	var packet: PoolByteArray
	if Configurations.get("SplitType"):
		packet = JSON.print({"command": "reset"},"\t").to_utf8()
	else:
		packet = "reset".to_utf8()
	return packet

func pause_igt_command():
	var packet: PoolByteArray
	if Configurations.get("SplitType"):
		packet = JSON.print({"command": "pauseGameTime"},"\t").to_utf8()
	else:
		packet = "pausegametime".to_utf8()
	return packet
	
func resume_igt_command():
	var packet: PoolByteArray
	if Configurations.get("SplitType"):
		packet = JSON.print({"command": "resumeGameTime"},"\t").to_utf8()
	else:
		packet = "resumegametime".to_utf8()
	return packet

func has_peer() -> bool:
	return websocket_server.has_peer(remote_peer_id)

func _on_client_connected(id: int, protocol: String):
	print("Client connected with id " + str(id) + " and protocol " + protocol)
	remote_peer_id = id
	

func _on_data_received(id: int):
	var message = websocket_server.get_peer(id).get_packet().get_string_from_utf8()
	print("Received message: " + message)
