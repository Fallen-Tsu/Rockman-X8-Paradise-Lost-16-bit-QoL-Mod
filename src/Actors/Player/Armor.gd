extends Node2D

export var show_head := false
export var show_body := false
export var show_arms := false
export var show_legs := false
var last_armor_collected := "nothing"

export var NeutralColor1 : Color
export var NeutralColor2 : Color
export var NeutralColor3 : Color
export var HermesColor1 : Color
export var HermesColor2 : Color
export var HermesColor3 : Color
export var IcarusColor1 : Color
export var IcarusColor2 : Color
export var IcarusColor3 : Color
export var UltimateColor1 : Color = Color("#132247")
export var UltimateColor2 : Color = Color("#d479e4")
export var UltimateColor3 : Color = Color("#60008d")
export var UltimateColor4: Color = Color("#29345b")
export var UltimateInner1 : Color = Color("#687ccc")
export var UltimateInner2 : Color = Color("#2c3956")
export var BodyColor1 : Color
export var BodyColor2 : Color
var InnerColor1: Color = Color("#78d8f0")
var InnerColor2: Color = Color("#50a0f0")
onready var NeutralColors = [NeutralColor1,NeutralColor2,NeutralColor3]
onready var HermesColors = [HermesColor1,HermesColor2,HermesColor3]
onready var IcarusColors = [IcarusColor1,IcarusColor2,IcarusColor3]
onready var UltimateColors = [UltimateColor1,UltimateColor2,UltimateColor3,UltimateColor4]
onready var BodyColors = [Color.pink, BodyColor1,BodyColor2]
var transition_time = 0.0

onready var character = get_parent()
onready var playerSprite = character.get_node("animatedSprite")
onready var head_armor = playerSprite.get_node("head_armor")
onready var body_armor = playerSprite.get_node("body_armor")
onready var arms_armor = playerSprite.get_node("arms_armor")
onready var cann_armor = playerSprite.get_node("cannon_armor")
onready var legs_armor = playerSprite.get_node("legs_armor")
onready var armor = [head_armor,body_armor,arms_armor,cann_armor,legs_armor]

func _ready() -> void:
	Event.listen("collected", self, "collected")
	Event.listen("x_appear", self, "flash_family_colors")

func collected(collectible : String):
	if "hermes" in collectible:
		last_armor_collected = collectible.replace("hermes_","")
	elif "icarus" in collectible:
		last_armor_collected = collectible.replace("icarus_","")
	elif "ultimate" in collectible:
		last_armor_collected = collectible.replace("ultimate_","")


func display(full_part_name : String):
	var part_location = full_part_name.replace("icarus_","").replace("hermes_","").replace("ultimate_","")
	call("display_" + part_location)
	var armor_set = full_part_name.split("_")[0]
	var colors
	var method_to_color = "change_colors"
	match (armor_set):
		"icarus":
			colors = IcarusColors
		"hermes":
			colors = HermesColors
		"ultimate":
			colors = UltimateColors
			method_to_color = "change_ultimate_colors"
		
	for part in armor:
		if part_location in part.name or (part_location == "arms" and "cannon" in part.name):
			part.family = armor_set
			if is_using_full_set():
				apply_family_color(armor_set)
			else:
				callv(method_to_color,[part,colors])
				turn_yellow_over_time()
	
	var inner1 = InnerColor1
	var inner2 = InnerColor2
	if "ultimate" in full_part_name:
		inner1 = UltimateInner1
		inner2 = UltimateInner2
	playerSprite.material.set_shader_param("R_MainColor4", inner1)
	playerSprite.material.set_shader_param("R_MainColor5", inner2)
	
func flash_family_colors():
	if not is_using_full_set():
		for part in armor:
			if part.family == "icarus":
				change_colors(part,IcarusColors)
				turn_yellow_over_time()
			elif part.family == "hermes":
				change_colors(part,HermesColors)
				turn_yellow_over_time()

func apply_family_color(family_name : String) -> void:
	for part in armor:
		part.stop_going_to_neutral_colors()
		if "neutral" in family_name:
			change_colors(part,NeutralColors)
		elif "icarus" in family_name:
			change_colors(part,IcarusColors)
		elif "hermes" in family_name:
			change_colors(part,HermesColors)
		elif "ultimate" in family_name:
			change_ultimate_colors(part,UltimateColors)

func change_colors(part, new_colors):
	part.material.set_shader_param("R_MainColor1", Color("#808080"))
	part.material.set_shader_param("R_MainColor2", Color("#865875"))
	part.material.set_shader_param("R_MainColor3", Color("#59364c"))
	part.material.set_shader_param("R_MainColor4", new_colors[0])
	part.material.set_shader_param("R_MainColor5", new_colors[1])
	part.material.set_shader_param("R_MainColor6", new_colors[2])
	part.material.set_shader_param("R_MainColor7", Color("#f0f0f0"))

func change_ultimate_colors(part, new_colors):
	part.material.set_shader_param("R_MainColor1", new_colors[0])
	part.material.set_shader_param("R_MainColor2", new_colors[1])
	part.material.set_shader_param("R_MainColor3", new_colors[2])
	part.material.set_shader_param("R_MainColor4", NeutralColor1)
	part.material.set_shader_param("R_MainColor5", NeutralColor2)
	part.material.set_shader_param("R_MainColor6", NeutralColor3)
	part.material.set_shader_param("MainColor7",Color("#f0f0f0"))
	part.material.set_shader_param("R_MainColor7", new_colors[3])

func _process(_delta: float) -> void:
	handle_armor_visibleness()
	synchronize_part_animations(character.get_animation())
	synchronize_shaders()

func is_using_full_set():
	var icarus_parts := 0
	var hermes_parts := 0
	var ultimate_parts := 0
	for part in character.current_armor:
		if "icarus" in part:
			icarus_parts += 1
		elif "hermes" in part:
			hermes_parts += 1
		elif "ultimate" in part:
			ultimate_parts += 1
	return icarus_parts == 4 or hermes_parts == 4 or ultimate_parts == 4

func turn_yellow_over_time():
	for part in armor:
		part.go_to_neutral_colors()

func synchronize_shaders() -> void:
	var _chargecolor = character.animatedSprite.material.get_shader_param("Color")
	var _charge = character.animatedSprite.material.get_shader_param("Charge")
	var _alpha = character.animatedSprite.material.get_shader_param("Alpha")
	var _flash = character.animatedSprite.material.get_shader_param("Flash")
	
	for part in armor:
		part.material.set_shader_param("Color", _chargecolor)
		part.material.set_shader_param("Charge", _charge)
		part.material.set_shader_param("Alpha", _alpha)
		part.material.set_shader_param("Flash", _flash)


func synchronize_part_animations(character_animation :String)-> void:
	var anim_to_play
	if character_animation == "recover" and is_shooting():
		anim_to_play = "shot_recover"
	else:
		anim_to_play = character_animation
	
	for part in armor:
		if "armor" in character_animation:
			if last_armor_collected in part.name:
				play_animation_on_part(part, anim_to_play)
		else:
			play_animation_on_part(part, anim_to_play)

func play_animation_on_part(part, anim_to_play):
	if get_animation(part) != anim_to_play:
		part.play(anim_to_play)
	if playerSprite.frame != part.frame:
		part.frame = playerSprite.frame
	

func enable_part_visual(partname :String) -> void:
	for part in armor:
		if partname in part.name:
			part.visible = true
	
func disable_part_visual(partname :String) -> void:
	for part in armor:
		if partname in part.name:
			part.visible = false

func get_animation(part) -> String:
	return part.animation

func is_shooting() -> bool:
	return playerSprite.frames.resource_name == "pointing_cannon"
	
func handle_armor_visibleness():
	head_armor.visible = show_head
	body_armor.visible = show_body
	legs_armor.visible = show_legs
	swap_arms_and_cannon()

func swap_arms_and_cannon():
	if is_shooting() and show_arms:
		arms_armor.visible = false
		cann_armor.visible = true
	elif not is_shooting() and show_arms:
		arms_armor.visible = true
		cann_armor.visible = false
	else: #show_arms == false
		arms_armor.visible = false
		cann_armor.visible = false

func display_head():
	show_head = true

func display_body():
	show_body = true

func display_arms():
	show_arms = true

func display_legs():
	show_legs = true
	
func hide_head():
	show_head = false

func hide_body():
	show_body = false

func hide_arms():
	show_arms = false

func hide_legs():
	show_legs = false
