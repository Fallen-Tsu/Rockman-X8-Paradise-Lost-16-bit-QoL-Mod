extends Movement
class_name Fall
var dash_momentum = 210

export var shot_pos_adjust := Vector2 (4,-5)


func get_shot_adust_position() -> Vector2:
	return shot_pos_adjust
		
func _ready() -> void:
	emit_land_sounds_on_event()
	
func emit_land_sounds_on_event():
	if active:
		if character.name == null:
			character.listen("land",self,"play_land_sound")

func play_land_sound():
	if character.listening_to_inputs:
		Log("Playing Land Sound")
		play_sound(null)

func play_animation_on_initialize():
	if animation:
		if character.get_animation() != animation:
			character.play_animation(animation)

func _Update(_delta: float) -> void:
	process_gravity(_delta)
	change_animation_if_falling("fall")
	zero_bonus_horizontal_speed()
	if character.dashfall:
		set_movement_and_direction(dash_momentum, _delta)
	else:
		set_movement_and_direction(horizontal_velocity, _delta)
	#decay_bonus_horizontal_speed()

func _Setup():
	character.global_position.y += 1

func _Interrupt() -> void:
	character.dashfall = false
	._Interrupt()

func Initialize() -> void:
	.Initialize()
	jumpcast_timer = 0

func BeforeEveryFrame(delta) -> void:
	.BeforeEveryFrame(delta)
	activate_low_jumpcasts_after_delay(delta)
	

func _StartCondition() -> bool:
	if not character.is_on_floor():
		return true
	
	return false

func _EndCondition() -> bool:
	if character.is_on_floor():
		return true
	return false
