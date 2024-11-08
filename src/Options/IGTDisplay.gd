extends X8OptionButton

func setup() -> void:
	set_igt_display(get_igt_display())
	display()

func increase_value() -> void: #override
	set_igt_display(!get_igt_display())
	display()

func decrease_value() -> void: #override
	set_igt_display(!get_igt_display())
	display()


func set_igt_display(value:bool) -> void:
	Configurations.set("IGTDisplay",value)
	

func get_igt_display() -> bool:
	if Configurations.get("IGTDisplay"):
		return true
	else:
		return false

func display():
	if Configurations.get("IGTDisplay"):
		display_value("ON_VALUE")
	else:
		display_value("OFF_VALUE")
