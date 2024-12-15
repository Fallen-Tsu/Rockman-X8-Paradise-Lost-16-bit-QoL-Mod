extends KinematicBody2D
onready var light: Light2D = $light
onready var charge_sound: AudioStreamPlayer2D = $"../charge_sound"
onready var full_energy: AudioStreamPlayer2D = $"../full_energy"

onready var tween := TweenController.new(self,false)
var charge_level := 0.0
var fully_energized := false
onready var doors: Node2D = $"../doors"

signal lit

func _ready() -> void:
	if GlobalVariables.get("pitch_black_energized"):
		call_deferred("full_energy")
	

func energize() -> void:
	if charge_level < 0:
		flash()
	elif not fully_energized:
		full_energy()

func full_energy() -> void:
	final_flash()
	fully_energized = true
	tween.attribute("position:y",-98,1.5,doors)
	Event.emit_signal("pitch_black_energized")
	GlobalVariables.set("pitch_black_energized", true)
	set_collision_layer_bit(21,false)
	Event.emit_signal("screenshake",2.0)
	emit_signal("lit")

func flash() -> void:
	charge_sound.play()
	charge_sound.pitch_scale += 0.05
	light.energy = 1.1
	tween.reset()
	tween.attribute("energy",0,0.35,light)
	charge_level += 1.0

func final_flash() -> void:
	full_energy.play()
	light.texture_scale = 20
	light.energy = 1.25
	tween.reset()
	tween.attribute("energy",0,4.75,light)
	charge_level += 1.0
