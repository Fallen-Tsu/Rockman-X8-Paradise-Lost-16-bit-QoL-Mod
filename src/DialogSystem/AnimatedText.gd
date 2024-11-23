extends Label
class_name DialogBox
onready var letter_sound : AudioStreamPlayer = $audioStreamPlayer
onready var portrait_1: AnimatedSprite = $Portrait1
onready var portrait_2: AnimatedSprite = $Portrait2
onready var bg: Sprite = $BG
onready var next_dialogue: AnimatedSprite = $next_dialogue
onready var portrait_side: Label = $portrait_side

export var is_final_dialogue := false
export var debug_messages := true
export var debug_force_start := false
export var dialog_tree : Resource
export var emit_capsule_signal := true
export var resume_character_inputs := true
var dialog_step := 0
var total_steps := 0
var timer := 0.0001
var time_between_letters := 0.055
var bg_scale : Vector2
var bg_grow_speed := 2
var text_to_display := ""
var state := "stopped"
var character := "Default"

signal dialog_concluded

const portrait_position_1 := 15
const portrait_position_2 := 175

func _ready() -> void:
	bg_scale = bg.scale
	bg.scale = Vector2.ZERO
	hide_text()
	hide_portraits()
	hide_next_arrow()
	GameManager.dialog_box = self
	if debug_force_start:
		startup()

func startup(alt_dialog_tree = null) -> void:
	bg.scale = Vector2.ZERO
	hide_text()
	hide_portraits()
	hide_next_arrow()
	if alt_dialog_tree:
		dialog_tree = alt_dialog_tree
	dialog_step = 0
	load_dialog_tree()
	state = "growing"
	Event.emit_signal("dialog_started")

func handle_extra_lines() -> void:
	var complete_text = text_to_display.split(" ",false)
	text = ""
	portrait_side.text = ""

	for word in complete_text:
		if get_line_count() <= 3:
			text += word + " "
		else:
			portrait_side.text += word + " "

	if get_line_count() > 3:
		take_last_word_from_text_and_add_to_side_text()

func take_last_word_from_text_and_add_to_side_text() -> void:
	var top_text = text.split(" ")
	var last_word = top_text[top_text.size()-2] #BANDAID: sempre eh adicionado um vazio a mais
	portrait_side.text = portrait_side.text.insert(0,last_word + " ")
	var correct_txt = text
	correct_txt.erase(text.length()-last_word.length()-1, last_word.length())
	text = correct_txt
	

func load_dialog_tree() -> void:
	total_steps = dialog_tree.dialog.size()
	state = "growing"
	load_step() 

func load_step() -> void:
	if total_steps <= dialog_step:
		hide_text()
		hide_portraits()
		hide_next_arrow()
		state = "shrinking"
		debug_print("Over step count. Shrinking dialog box.")
		return
	var step = get_current_step()
	#debug_print ("Loaded Step")
	if step is DialogueProfile:
		setup_character(step)
		increase_step()
		load_step()
	elif step is String:
		text_to_display = tr(step)
		handle_extra_lines() 
		hide_text()
		state = "entering_text"
		debug_print("Loaded text: " + text)
		debug_print(portrait_side.text)

func increase_step() -> void:
	dialog_step = dialog_step + 1
	debug_print ("Increased step, now: " + str(dialog_step))

func setup_character(step) -> void:
	portrait_1.frames = step.portrait_animations
	material.set_shader_param("palette", step.text_palette)
	letter_sound.pitch_scale = step.audio_pitch
	if step.name == "MegaMan X":
		portrait_1.position.x = portrait_position_1
		portrait_side.margin_left = 36
		portrait_side.margin_right = 176
	else:
		portrait_1.position.x = portrait_position_2
		portrait_side.margin_left = 0
		portrait_side.margin_right = 141
	character = step.name
	debug_print("Loaded Character: " + character)

func get_current_step():
	return dialog_tree.dialog[dialog_step]

func _physics_process(delta: float) -> void:
	if state != "stopped":
		if player_forced_end_of_dialog():
			force_end()
	
	if state == "growing":
		grow(delta)
	
	elif state == "entering_text":
		enter_text(delta)
	
	elif state == "waiting_input":
		wait_input()
	
	elif state == "shrinking":
		shrink(delta)

func player_forced_end_of_dialog() -> bool:
	if Configurations.exists("SkipDialog"):
		if Configurations.get("SkipDialog"):
			if is_final_dialogue:
				return Input.is_action_pressed("pause")
			else:
				return Input.is_action_pressed("pause") or Configurations.get("AutoSkipDialog")
	return false

func grow(delta: float) -> void:
	if bg.scale.x < bg_scale.x:
		bg.scale.x += delta * bg_grow_speed
	if bg.scale.y < bg_scale.y:
		bg.scale.y += delta * bg_grow_speed
	if bg.scale.y > bg_scale.y:
		bg.scale.y = bg_scale.y
	if bg.scale.x >= bg_scale.x:
		bg.scale = bg_scale
		state = "entering_text"
		portrait_1.visible = true

func enter_text(delta : float) -> void:
	timer += delta
	Event.emit_signal("character_talking",character)
	if timer > time_between_letters:
		portrait_1.animation = "talk"
		timer = 0
		#letter_sound.play()
		if not has_finished_displaying_chars():
			add_visible_char()
		elif not has_finished_displaying_side_chars():
			add_visible_side_char()

	if not has_side_text() and has_finished_displaying_chars() \
	or has_side_text() and has_finished_displaying_side_chars() or is_action_pressed():
		debug_print("Finished entering characters.")
		state = "waiting_input"
		Event.emit_signal("stopped_talking",character)

const invalid_characters := [" ","'",",",".","?","!","-"]

func play_sound_based_on_displayed_letter(letter : String):
	if not letter in invalid_characters:
		letter_sound.play()

func add_visible_char() -> void:
	visible_characters = visible_characters + 1
	play_sound_based_on_displayed_letter(text[visible_characters])

func add_visible_side_char() -> void:
	portrait_side.visible_characters = portrait_side.visible_characters + 1
	play_sound_based_on_displayed_letter(portrait_side.text[portrait_side.visible_characters])
	
func has_side_text() -> bool:
	return total_side_chars() != 0

func has_finished_displaying_side_chars() -> bool:
	return side_visible_chars() >= total_side_chars()

func has_finished_displaying_chars() -> bool:
	return visible_characters >= get_total_character_count()

func total_side_chars() -> int:
	return portrait_side.get_total_character_count()

func side_visible_chars() -> int:
	return portrait_side.visible_characters

func wait_input() -> void:
	Event.emit_signal("character_talking","none")
	visible_characters = get_total_character_count()
	portrait_side.visible_characters = total_side_chars()
	portrait_1.animation = "idle"
	next_dialogue.visible = true
	if is_action_pressed():
		hide_next_arrow()
		increase_step()
		load_step()

func shrink (delta: float) -> void:
	if bg.scale.x > 0:
		bg.scale.x -= delta * bg_grow_speed
	if bg.scale.y > 0:
		bg.scale.y -= delta * bg_grow_speed
	if bg.scale.y < 0:
		bg.scale.y = 0
	if bg.scale.y <= 0.01:
		end_dialog()

func force_end() -> void:
	hide_next_arrow()
	hide_portraits()
	hide_text()
	Event.emit_signal("character_talking","none")
	state = "shrinking"

func end_dialog() -> void:
	state = "stopped"
	hide_next_arrow()
	hide_portraits()
	hide_text()
	bg.scale = Vector2.ZERO
	emit_signal("dialog_concluded")
	Event.emit_signal("dialog_concluded")
	if resume_character_inputs:
		GameManager.resume_character_inputs()
	GameManager.save_seen_dialogue(dialog_tree)
	if emit_capsule_signal:
		Event.emit_signal("capsule_dialogue_end")
	

func is_action_pressed() -> bool:
	if Input.is_action_just_pressed("fire") or \
	   Input.is_action_just_pressed("ui_accept"):
		debug_print("Press detected.")
		return true
	return false

func debug_print (message : String) -> void:
	if debug_messages:
		print ("DialogSystem: " + message)

func hide_text() -> void:
	visible_characters = 0
	portrait_side.visible_characters = 0

func hide_next_arrow() -> void:
	next_dialogue.visible = false

func hide_portraits() -> void:
	portrait_1.visible = false
	portrait_2.visible = false

func _get_real_line_count():
	var line_count = get_line_count()
	var lines_to_add = 0
	#for i in line_count:
	#	var line = text
	#	var width = font.get_string_size(line).x
	return line_count + lines_to_add
