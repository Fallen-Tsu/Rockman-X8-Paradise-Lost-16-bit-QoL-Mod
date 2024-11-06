extends X8OptionButton

func setup() -> void:
	set_split_type(get_split_type())

func increase_value() -> void: #override
	set_split_type(!get_split_type())

func decrease_value() -> void: #override
	set_split_type(!get_split_type())

func set_split_type(value:bool) -> void:
	Configurations.set("SplitType",value)
	display_split_type()

func get_split_type():
	if Configurations.exists("SplitType"):
		return Configurations.get("SplitType")
	return false

func display_split_type():
	if Configurations.get("SplitType"):
		display_value("LiveSplit One")
	else:
		display_value("LiveSplit")
