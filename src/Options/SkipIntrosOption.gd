extends X8OptionButton

const SkipOptions = {
	0: "NO_INTRO_SKIP_VALUE",
	1: "INTRO_ONLY_SKIP_VALUE",
	2: "WEAPON_GET_ONLY_VALUE",
	3: "BOTH_SKIP_VALUE"
}

var current_value: int = 0

func _ready() -> void:
	Event.connect("translation_updated",self,"display_skip_intros")
	
func setup() -> void:
	set_skip_intros(get_skip_intros())

func increase_value() -> void: #override
	set_skip_intros((current_value + 1) % 4)

func decrease_value() -> void: #override
	# +4 if current_value == 0 so (0 -1 + 4) % 4 = 3
	# (1 - 1 + 4 ) % 4 = 0 and so on
	set_skip_intros((current_value - 1 + 4) % 4)

func set_skip_intros(value: int) -> void:
	Configurations.set("SkipIntros",value)
	current_value = value
	display_skip_intros()

func get_skip_intros():
	if Configurations.exists("SkipIntros"):
		return Configurations.get("SkipIntros")
	return 0

func display_skip_intros():
	if Configurations.get("SkipIntros"):
		display_value(SkipOptions[current_value])
	else:
		display_value("NO_INTRO_SKIP_VALUE")
