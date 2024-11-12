extends X8OptionButton


func _ready() -> void:
	Event.connect("translation_updated",self,"display_auto_skip_dialog")
	
func setup() -> void:
	set_auto_skip_dialog(get_auto_skip_dialog())

func increase_value() -> void: #override
	set_auto_skip_dialog(!get_auto_skip_dialog())

func decrease_value() -> void: #override
	set_auto_skip_dialog(!get_auto_skip_dialog())

func set_auto_skip_dialog(value:bool) -> void:
	Configurations.set("AutoSkipDialog",value)
	if value and not Configurations.get("SkipDialog"):
		Configurations.set("SkipDialog", value)
		Event.emit_signal("translation_updated")
	display_auto_skip_dialog()

func get_auto_skip_dialog():
	if Configurations.exists("AutoSkipDialog"):
		return Configurations.get("AutoSkipDialog")
	return false

func display_auto_skip_dialog():
	if Configurations.get("AutoSkipDialog"):
		display_value("ON_VALUE")
	else:
		display_value("OFF_VALUE")
