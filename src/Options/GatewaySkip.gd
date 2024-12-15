extends X8OptionButton

func setup() -> void:
	set_gateway_skip(get_gateway_skip())
	display()

func increase_value() -> void: #override
	set_gateway_skip(!get_gateway_skip())
	display()

func decrease_value() -> void: #override
	set_gateway_skip(!get_gateway_skip())
	display()


func set_gateway_skip(value:bool) -> void:
	Configurations.set("GatewaySkip",value)
	

func get_gateway_skip() -> bool:
	if Configurations.get("GatewaySkip"):
		return true
	else:
		return false

func display():
	if Configurations.get("GatewaySkip"):
		display_value("ON_VALUE")
	else:
		display_value("OFF_VALUE")
