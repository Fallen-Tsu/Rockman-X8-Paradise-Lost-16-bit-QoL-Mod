extends NewAbility

var exploded := false
export var should_explode_with_plasma : bool = true


onready var animation = AnimationController.new($"../animatedSprite",self)
onready var particles: Particles2D = $"Explosion Particles"
onready var explosion: AudioStreamPlayer2D = $explosion_sound
onready var collider: CollisionShape2D = $"../collisionShape2D"

func _StartCondition() -> bool:
	return character.able_to_explode and not exploded

func _Setup() -> void:
	exploded = true
	$punch_detector.active = false
	collider.set_deferred("disabled",true)
	animation.play("open")
	explosion.play()
	particles.emitting = true
	Tools.timer(1.5,"stop_visuals",self)
	Event.emit_signal("screenshake",2)

func stop_visuals() -> void:
	particles.emitting = false

func _on_punch_detector_body_entered(body) -> void:
	if body.name == "RideArmorPunch" or (body.name == "PlasmaShot" and should_explode_with_plasma):
		_on_signal()
	#elif body.name == "BlastLaunchCharged":
	#	body.hit(self)
	#''	_on_signal()
		
func damage(_d,_s) -> float:
	return 1.0

func _on_bike_detector_body_entered(body: Node) -> void:
	if not exploded:
		if body.is_in_group("Props") and "RideChaser" in body.get_character().name:
			if abs(body.get_character().get_actual_horizontal_speed() ) > 325:
				_on_signal()
				call_deferred("destroy_bike",body)

func destroy_bike(body): #TODO: mover para moto
	var bike = body.get_character()
	bike.set_actual_speed(bike.get_actual_speed()/2)
	bike.current_health = 0
	bike.get_node("Death").emit_remains_particles()
	if bike.is_executing("Riden"):
		bike.get_node("Riden").force_eject()
	bike.force_end("Dash")
	bike.force_end("HyperDash")
	bike.set_direction(-bike.get_direction())
	
