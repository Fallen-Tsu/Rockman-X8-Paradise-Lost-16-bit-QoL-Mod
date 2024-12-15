extends AnimatedSprite
class_name VisualArmorPart

export var debug := false

var family := "none"
var going_to_neutral_colors := false
var transition_time := 0.0
var original_color1 : Color
var original_color2 : Color
var original_color3 : Color
onready var armor = get_parent().get_parent().get_node("Armor").armor
onready var NeutralColors = get_parent().get_parent().get_node("Armor").NeutralColors

func get_armor():
	return 

func stop_going_to_neutral_colors():
	going_to_neutral_colors = false
	transition_time = 0.0
	

func _process(delta: float) -> void:
	if debug:
		Log.msg(name +": " + str(animation) + "." + str(frame))
	if going_to_neutral_colors:
		lerp_to_neutral_colors(delta)

func lerp_to_neutral_colors(delta) -> void:
	if transition_time <= 1:
		transition_time += delta/12
		for part in armor:
			material.set_shader_param("R_MainColor4", lerp(original_color1,NeutralColors[0], transition_time))
			material.set_shader_param("R_MainColor5", lerp(original_color2,NeutralColors[1], transition_time))
			material.set_shader_param("R_MainColor6", lerp(original_color3,NeutralColors[2], transition_time))
	else:
		going_to_neutral_colors = false
		transition_time = 0
	
func go_to_neutral_colors():
	going_to_neutral_colors = false
	original_color1 = material.get_shader_param("R_MainColor4")
	original_color2 = material.get_shader_param("R_MainColor5")
	original_color3 = material.get_shader_param("R_MainColor6")
	transition_time = 0.01
