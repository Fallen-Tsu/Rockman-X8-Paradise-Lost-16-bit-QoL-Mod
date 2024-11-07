extends LineEdit

onready var parent_button = $"../Button"
# Function to handle input
var old_text: String
func _ready():
	old_text = text
func _input(event):
	# Check if the "ui_accept" action (typically Enter key) is pressed
	if visible:
		if event is InputEventKey:
			if event.scancode == KEY_ESCAPE:
				text = old_text
				return_control()
			elif event.scancode == KEY_ENTER:
				emit_signal("text_entered", text)
				return_control()
		elif event.is_action_pressed("ui_accept"):
			emit_signal("text_entered", text)
			return_control()
		elif event.is_action_pressed("ui_up"):
			pass
		elif event.is_action_pressed("ui_down"):
			pass
		
func return_control():
	release_focus()
	old_text = text
	visible = false
	editable = false
	parent_button.menu.unlock_buttons()
	parent_button.value.visible = true
	parent_button.call_deferred("grab_focus")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
