extends X8TextureButton

onready var sound_effect_node = $"../../reset"
onready var action_holder = $"../scrollContainer/ActionHolder"
func _on_pressed() -> void:
	modulate = Color(3,3,3,1)
	reset_tween()
	tween.tween_property(self,"modulate",Color.white,.35) # warning-ignore:return_value_discarded
	InputMap.load_from_globals()
	InputManager.modified_keys.clear()
	sound_effect_node.play()
	action_holder.emit_signal("default_pressed")
