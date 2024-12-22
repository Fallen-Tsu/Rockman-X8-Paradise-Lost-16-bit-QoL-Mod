extends X8TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var no_parts : Array
var ultimate_parts: Array
onready var icon = $"../icon"
# Called when the node enters the scene tree for the first time.
func _ready():
	
	no_parts = [
		$"../../textureRect/Options Group/ArmorParts/HeadParts/head",
		$"../../textureRect/Options Group/ArmorParts/BodyParts/body",
		$"../../textureRect/Options Group/ArmorParts/ArmsParts/arms",
		$"../../textureRect/Options Group/ArmorParts/LegsParts/legs",
	]
	ultimate_parts = [
		$ArmorParts/HeadParts/ultimate_head,
		$ArmorParts/BodyParts/ultimate_body,
		$ArmorParts/ArmsParts/ultimate_arms,
		$ArmorParts/LegsParts/ultimate_legs,
	]
	icon.visible = get_parent().visible


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_entered():
	play_sound()
	flash()


func _on_ultimateButton_toggled(button_pressed):
	if !button_pressed:
		for part in no_parts:
			part.on_press()
		Event.emit_signal("mixed_set")
	else:
		for part in ultimate_parts:
			part.on_press()
		Event.emit_signal("full_ultimate")
