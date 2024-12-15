extends Area2D
onready var sprite: AnimatedSprite = $"../animatedSprite"

var active := true
var hit_times := 0
onready var hit: AudioStreamPlayer2D = $hit

signal destroyed

func blink() -> void:
	sprite.material.set_shader_param("Flash",1)
	Tools.timer(0.033,"unblink",self)

func unblink() -> void:
	sprite.material.set_shader_param("Flash",0)

func _on_ArrowDetector_body_entered(body: Node) -> void:
	if active:
		print(body.name)
		if "DarkArrowCharged" in body.name:
			on_darkarrow_hit(3)
			body._OnHit(0)
		elif "DarkArrow" in body.name:
			on_darkarrow_hit(1)
			body._OnHit(100)
		elif "DamageArea" in body.name:
			on_darkarrow_hit(3)

func on_darkarrow_hit(amount : int) -> void:
	blink()
	hit.play()
	hit_times += amount
	if hit_times >= 3:
		emit_signal("destroyed")
		active = false

func deactivate() -> void:
	active = false
