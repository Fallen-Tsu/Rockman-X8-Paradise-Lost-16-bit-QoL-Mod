extends X8OptionButton

func setup() -> void:
	set_split_on_bosskill(get_split_on_bosskill())

func increase_value() -> void: #override
	set_split_on_bosskill(!get_split_on_bosskill())

func decrease_value() -> void: #override
	set_split_on_bosskill(!get_split_on_bosskill())

func set_split_on_bosskill(value:bool) -> void:
	Configurations.set("SplitOnBossKill",value)
	display_split_on_bosskill()

func get_split_on_bosskill():
	if Configurations.exists("SplitOnBossKill"):
		return Configurations.get("SplitOnBossKill")
	return false

func display_split_on_bosskill():
	if Configurations.get("SplitOnBossKill"):
		display_value("ON_VALUE")
	else:
		display_value("OFF_VALUE")
