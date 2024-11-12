extends X8OptionButton


func _ready() -> void:
	Event.connect("translation_updated",self,"display_skip_dialog")
	
func setup() -> void:
	set_skip_dialog(get_skip_dialog())

func increase_value() -> void: #override
	set_skip_dialog(!get_skip_dialog())

func decrease_value() -> void: #override
	set_skip_dialog(!get_skip_dialog())

func set_skip_dialog(value:bool) -> void:
	Configurations.set("SkipDialog",value)
	if not value and Configurations.get("AutoSkipDialog"):
		Configurations.set("AutoSkipDialog", value)
		Event.emit_signal("translation_updated")
	display_skip_dialog()

func get_skip_dialog():
	if Configurations.exists("SkipDialog"):
		return Configurations.get("SkipDialog")
	return false

func display_skip_dialog():
	if Configurations.get("SkipDialog"):
		display_value("ON_VALUE")
	else:
		display_value("OFF_VALUE")
