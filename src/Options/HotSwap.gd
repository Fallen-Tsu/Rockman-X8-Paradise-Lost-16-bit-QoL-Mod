extends Node2D

const travel_distance := 40.0
export var locked_icon : Texture
onready var cursor: Sprite = $cursor
onready var tweenx := TweenController.new(self,false)
onready var tweeny := TweenController.new(self,false)
var idle_time := 0.0
onready var choice: AudioStreamPlayer2D = $choice

var active := true

signal weapon_selected(weapon)
signal unselected_all()

var using_buttons := false

var analogs = ["analog_left","analog_right","analog_up","analog_down"]

func _input(event: InputEvent) -> void:
	if not active:
		return
	
	if not using_buttons:
		for input in analogs:
			if event.is_action_pressed(input):
				if event is InputEventKey or event is InputEventJoypadButton:
					using_buttons = true
					break
				elif event is InputEventJoypadMotion:
					using_buttons = false
					break
	
	if using_buttons:
		if event.is_action_pressed("analog_left"):
			cursor.position.x = -travel_distance
			tweenx.reset()
		elif event.is_action_pressed("analog_right"):
			cursor.position.x = travel_distance
			tweenx.reset()
		elif event.is_action_released("analog_right") or event.is_action_released("analog_left"):
			slowly_reset_x_cursor()
			
		if event.is_action_pressed("analog_up"):
			cursor.position.y = -travel_distance
			tweeny.reset()
		elif event.is_action_pressed("analog_down"):
			cursor.position.y = travel_distance
			tweeny.reset()
		elif event.is_action_released("analog_down") or event.is_action_released("analog_up"):
			slowly_reset_y_cursor()
		
		if event.is_action_pressed("analog_up_left"):
			cursor.position = Vector2(-travel_distance, -travel_distance)
			tweeny.reset()
			tweenx.reset()
		elif event.is_action_pressed("analog_down_right"):
			cursor.position = Vector2(travel_distance, travel_distance)
			tweeny.reset()
			tweenx.reset()
		elif event.is_action_released("analog_down_right") or event.is_action_released("analog_up_left"):
			slowly_reset_y_cursor()
			slowly_reset_x_cursor()
		
		if event.is_action_pressed("analog_up_right"):
			cursor.position = Vector2(travel_distance, -travel_distance)
			tweeny.reset()
			tweenx.reset()
		elif event.is_action_pressed("analog_down_left"):
			cursor.position = Vector2(-travel_distance, travel_distance)
			tweeny.reset()
			tweenx.reset()
		elif event.is_action_released("analog_down_left") or event.is_action_released("analog_up_right"):
			slowly_reset_y_cursor()
			slowly_reset_x_cursor()

func slowly_reset_x_cursor():
	tweenx.reset()
	tweenx.attribute("position:x",0.0,.1,cursor)
	
func slowly_reset_y_cursor():
	tweeny.reset()
	tweeny.attribute("position:y",0.0,.1,cursor)

func _ready() -> void:
	Event.listen("weapon_select_buster",self,"selected_buster")
	Event.listen("weapon_select_right",self,"selected_buster")
	Event.listen("weapon_select_left",self,"selected_buster")
	Event.connect("player_death",self,"deactivate")

func deactivate():
	active = false

func _physics_process(delta: float) -> void:
	if not using_buttons:
		var analog_left = Input.get_action_strength("analog_left")
		var analog_right = Input.get_action_strength("analog_right")
		var analog_up = Input.get_action_strength("analog_up")
		var analog_down = Input.get_action_strength("analog_down")
		cursor.position.x = (analog_right - analog_left) * travel_distance
		cursor.position.y = (analog_down - analog_up) * travel_distance
	
	if cursor.position == Vector2.ZERO:
		idle_time += delta
		
		if idle_time > .15:
			modulate.a = 1.15 - idle_time * 2
	else:
		idle_time = 0
		modulate.a = 1

func selected_buster() -> void:
	idle_time =2
	cursor.position = Vector2.ZERO
	emit_signal("unselected_all")

func _on_cursor_area_entered(area: Area2D) -> void:
	var selected = area.get_parent()
	if selected.selectable and not selected.already_selected: 
		selected.select() 
		choice.play()
		emit_signal("weapon_selected",selected)
