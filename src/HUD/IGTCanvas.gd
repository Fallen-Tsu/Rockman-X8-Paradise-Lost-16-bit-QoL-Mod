extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var total_time_label = $IGTRect/IGTLabelContainer/TotalTime
onready var stage_time_label = $IGTRect/IGTLabelContainer/node2D/StageTime

# Called when the node enters the scene tree for the first time.
func _ready():
	Configurations.connect("value_changed", self, "_on_igt_value_changed")
	if Configurations.get("IGTDisplay"):
		visible = true
	else:
		visible = false


func _on_igt_value_changed(key):
	if key == "IGTDisplay":
		visible = Configurations.get("IGTDisplay")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	total_time_label.text = Tools.get_full_readable_time(IGT.total_time)
	if IGT.times.has(IGT.current_section):
		stage_time_label.text = Tools.get_full_readable_time(IGT.times[IGT.current_section])
