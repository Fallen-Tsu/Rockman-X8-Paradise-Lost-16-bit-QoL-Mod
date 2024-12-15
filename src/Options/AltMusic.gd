extends X8OptionButton

func setup() -> void:
	set_alt_music(get_alt_music())
	display()

func increase_value() -> void: #override
	set_alt_music(!get_alt_music())
	display()

func decrease_value() -> void: #override
	set_alt_music(!get_alt_music())
	display()


func set_alt_music(value:bool) -> void:
	Configurations.set("AltMusic",value)
	

func get_alt_music() -> bool:
	if Configurations.get("AltMusic"):
		return true
	else:
		return false

func display():
	if Configurations.get("AltMusic"):
		display_value("ON_VALUE")
	else:
		display_value("OFF_VALUE")
