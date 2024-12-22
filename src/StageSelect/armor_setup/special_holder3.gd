extends TextureRect



# Called when the node enters the scene tree for the first time.
func _ready():
	visible = "ultimate_arms" in GameManager.collectibles
