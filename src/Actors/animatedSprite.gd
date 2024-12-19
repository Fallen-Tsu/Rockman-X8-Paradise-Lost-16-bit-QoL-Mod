extends AnimatedSprite

onready var head: AnimatedSprite = $head_armor
onready var body: AnimatedSprite = $body_armor
onready var arms: AnimatedSprite = $arms_armor
onready var cannon: AnimatedSprite = $cannon_armor
onready var legs: AnimatedSprite = $legs_armor
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameManager.used_cheat_code:
		head.modulate=Color("#004a41")
		body.modulate=Color("#004a41")
		arms.modulate=Color("#004a41")
		cannon.modulate=Color("#004a41")
		legs.modulate=Color("#004a41")
		head.visible = true
		body.visible = true
		arms.visible = true
		legs.visible = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
