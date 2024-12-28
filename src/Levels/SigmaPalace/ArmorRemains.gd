extends Sprite


func _ready() -> void:
	Tools.timer(0.1,"check_for_armor",self)
	pass

func check_for_armor():
	for item in GameManager.current_armor:
		if "hermes" in item:
			return
		elif "icarus" in item:
			return
		elif "ultimate" in item:
			return
	
	push_warning("TODO: Remember to set current armor after Lumine 2")
	queue_free()
