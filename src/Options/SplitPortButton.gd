extends X8TextureButton

var active := false
onready var value: Label = $Value
onready var port_input = $"../PortInput"
var frequency := 0.5
var timer := 0.0

func _ready() -> void:
	var _s = Savefile.connect("loaded",self,"setup")
	port_input.visible = false
	port_input.editable = false
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
	show_spinbox()

func setup() -> void:
	set_split_port(get_split_port())

func set_split_port(value:int) -> void:
	Configurations.set("SplitPort",value)
	display_split_port()

func get_split_port():
	if Configurations.exists("SplitPort"):
		return Configurations.get("SplitPort")
	return false

func display_split_port():
	if Configurations.get("SplitPort"):
		port_input.value = get_split_port()
		display_value(port_input.value)
	else:
		display_value(16834)

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
		show_spinbox()
		play_sound()
		reduce_frequency()
	else:
		timer = 0
		frequency = 0.5
		
		
func show_spinbox() -> void: #override
	port_input.visible = true
	port_input.editable = true
	value.visible = false
	_on_focus_exited()
	port_input.grab_focus()
	menu.lock_buttons()

func display_value(new_value) -> void:
	value.text = tr(str(new_value))
