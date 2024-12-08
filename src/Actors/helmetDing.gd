extends AnimatedSprite

onready var finish_node = $"../Finish"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if animation == "victory" and IGT.can_split:
		IGT.calculate_total_time()
		IGT.send_command("split_command")
		IGT.can_split = false
	if animation == "beam_in" and IGT.can_split and finish_node.victoring:
		IGT.calculate_total_time()
		IGT.send_command("split_command")
		IGT.can_split = false
