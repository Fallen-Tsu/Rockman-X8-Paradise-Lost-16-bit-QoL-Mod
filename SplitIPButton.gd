extends X8TextureButton

var active := false
onready var value: Label = $Value
onready var line_edit = $"../IpInput"
var frequency := 0.5
var timer := 0.0

func _ready() -> void:
	var _s = Savefile.connect("loaded",self,"setup")
	line_edit.visible = false
	line_edit.editable = false
	Event.listen("update_options",self,"setup")


func _on_focus_exited() -> void:
	._on_focus_exited()
	active = false

func _on_focus_entered() -> void:
	._on_focus_entered()
	active = true

func on_press() -> void:
	strong_flash()
	play_sound()
	show_line_edit()

func setup() -> void:
	set_split_ip(get_split_port())

func set_split_ip(value: String) -> void:
	Configurations.set("SplitIP",value)
	display_split_ip()

func get_split_port():
	if Configurations.exists("SplitIP"):
		return Configurations.get("SplitIP")
	return "127.0.0.1"

func display_split_ip():
	if Configurations.get("SplitIP"):
		line_edit.text = get_split_port()
		display_value(line_edit.text)
	else:
		display_value("127.0.0.1")

#func _physics_process(delta: float) -> void:
#	if active:
#		timer += delta
#		if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
#			if frequency == 0.5:
#				process_inputs()
#			elif timer > frequency:
#				process_inputs()
#		else:
#			timer = 0
#			frequency = 0.5

func reduce_frequency() -> void:
	frequency = frequency * 0.8
	frequency = clamp(frequency,0.04,0.5)

func process_inputs() -> void:
	timer = 0
	if Input.is_action_pressed("ui_accept"):
		flash()
		show_line_edit()
		play_sound()
		reduce_frequency()
	else:
		timer = 0
		frequency = 0.5
		
		
func show_line_edit() -> void: #override
	line_edit.visible = true
	line_edit.editable = true
	value.visible = false
	_on_focus_exited()
	line_edit.grab_focus()
	menu.lock_buttons()

func display_value(new_value) -> void:
	value.text = tr(str(new_value))
