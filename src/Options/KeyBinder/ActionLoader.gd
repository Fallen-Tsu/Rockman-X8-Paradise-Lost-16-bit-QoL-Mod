extends VBoxContainer

export (PackedScene) var input_holder
onready var main: CanvasLayer = $"../../.."
signal default_pressed

var configurable = {
	"move_left" : "LEFT_ACT",
	"move_right" : "RIGHT_ACT",
	"move_up" : "UP_ACT",
	"move_down" : "DOWN_ACT",
	"fire" : "SHOT_ACT",
	"alt_fire" : "SHOT2_ACT",
	"jump" : "JUMP_ACT",
	"dash" : "DASH_ACT",
	"select_special" : "ARMORABILITY_ACT",
	"weapon_select_left" : "PREV_ACT",
	"weapon_select_right" : "NEXT_ACT",
	"pause" : "PAUSE_ACT",
	#"select" : "Options Menu",
	"ui_accept" : "CONFIRM_ACT",
	"analog_left" : "WPNLEFT_ACT",
	"analog_right" : "WPNRIGHT_ACT",
	"analog_up" : "WPNUP_ACT",
	"analog_down" : "WPNDOWN_ACT",
	"analog_up_left": "WPNUPLEFT_ACT",
	"analog_up_right": "WPNUPRIGHT_ACT",
	"analog_down_left": "WPNDOWNLEFT_ACT",
	"analog_down_right": "WPNDOWNRIGHT_ACT",
	"reset_weapon" : "WPNRESET_ACT",
}

onready var exit: TextureButton = $"../../exit"

func _ready() -> void:
	Setup_actions()

func emit_default_pressed() -> void:
	emit_signal("default_pressed")

func Setup_actions() -> void:
	var last_child
	for action in configurable.keys():
		last_child = instantiate(action)
	Set_neighbours(last_child)

func instantiate(action) -> Node:
	var instance = input_holder.instance()
	connect("default_pressed", instance, "get_inputs_and_set_names_after_reset")
	add_child(instance,true)
	instance.setup(action, configurable[action], main)
	return instance

func Set_neighbours(last_child) -> void:
	exit.focus_neighbour_top = last_child.get_child(0).get_path()
	exit.focus_neighbour_bottom = get_child(0).get_child(0).get_path()
	get_child(0).get_child(0).focus_neighbour_top = exit.get_path()
	get_child(0).get_child(1).focus_neighbour_top = exit.get_path()
	last_child.get_child(0).focus_neighbour_bottom = exit.get_path()
	last_child.get_child(1).focus_neighbour_bottom = exit.get_path()
