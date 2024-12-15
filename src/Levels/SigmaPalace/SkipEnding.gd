extends CanvasLayer

onready var visual_skip: Control = $VisualSkip
onready var credits_scene: Node2D = $".."

var skip_timer := 0.0
var total_timer := 0.0
var finished = false

func _physics_process(delta: float) -> void:
	total_timer += delta
	
	if finished or not total_timer > 15:
		return
	visual_skip.fill(skip_timer)
	if Input.is_action_pressed("pause"):
		skip_timer += delta
		visual_skip.fadein()

	elif Input.is_action_just_released("pause"):
		skip_timer = 0
		visual_skip.fadeout()
	
	if skip_timer > 4:
		visual_skip.visible = false
		credits_scene.fade_out()
		finished = true
