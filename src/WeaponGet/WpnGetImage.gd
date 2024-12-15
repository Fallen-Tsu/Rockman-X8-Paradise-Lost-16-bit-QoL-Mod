extends Node2D

export var weapons : Array
export var text_palette : Texture

var current_weapon : WeaponResource

onready var parts : Array = get_children()
onready var tween := TweenController.new(self,false)
onready var music: AudioStreamPlayer = $"../audioStreamPlayer"
onready var text: Node2D = $"../text"
onready var you_get: Label = $"../text/you_get"
onready var weapon_name: Label = $"../text/weapon_name"
onready var get_shadow: Label = $"../text/get_shadow"
onready var name_shadow: Label = $"../text/name_shadow"
onready var names := [you_get,weapon_name,get_shadow,name_shadow]

onready var bar2: Sprite = $"../bar2"
onready var bar: Sprite = $"../bar"
onready var green_bg: Polygon2D = $"../green_bg"
const bar_pos = 147
onready var green_bg_pos:= green_bg.position
onready var o_pos:= position
onready var you_get_pos:= you_get.rect_position
onready var weapon_name_pos:= weapon_name.rect_position
onready var fullblack: Sprite = $"../fullblack"
onready var lines_2: Node2D = $"../lines2"
onready var audio: AudioStreamPlayer = $"../audioStreamPlayer"

signal move_in
signal start
signal reset

signal color(weapon)
signal defined_weapon(weapon)

var ending := false

func _input(event: InputEvent) -> void:
	if not ending:
		if event.is_action_pressed("pause"):
			tween.reset()
			fadeout(.5)
			GameManager.pause("weaponget")
			ending = true
	
func _ready() -> void:
	get_parent().connect("initialize",self,"delayed_initialize")
	reset()
	Tools.timer(2.0,"start_loop",lines_2)
	you_get.material.set_shader_param("palette",text_palette)
	var skip_type = Configurations.get("AutoSkipDialog")
	if skip_type:
			tween.reset()
			fadeout(.5)
			GameManager.pause("weaponget")
			ending = true
	
func delayed_initialize():
	Tools.timer(1.0,"initialize",self)
	
func initialize() -> void:
	if ending:
		return
	music.play()
	bars_expand()
	Tools.timer(5.5,"start",self,null,true)
	Tools.timer(7.2,"flash",self,null,true)
	Tools.timer(11.0,"move_things_away",self,null,true)
	Tools.timer(11.0,"fadeout",self,null,true)

func define_weapon_gotten() -> void:
	var weapon_gotten = GameManager.weapon_got
	if not weapon_gotten or weapon_gotten == "none":
		push_error("No Weapon defined, defining it as rooster_weapon for debug purposes")
		weapon_gotten = "rooster_weapon"
	for weapon in weapons:
		if weapon.collectible == weapon_gotten: #changed for debug GameManager.weapon_got
			current_weapon = weapon
	weapon_name.text = tr(current_weapon.collectible.to_upper())
	name_shadow.text = tr(current_weapon.collectible.to_upper())
	emit_signal("defined_weapon",current_weapon)

func reset():
	tween.reset()
	define_weapon_gotten()
	fullblack.modulate.a = 1
	visible = false
	bar.position.y = bar_pos
	bar2.position.y = bar_pos
	green_bg.scale.y = 0
	position = o_pos
	green_bg.position = green_bg_pos
	you_get.rect_position = you_get_pos
	weapon_name.rect_position = weapon_name_pos
	for n in names:
		n.visible = false
	emit_signal("reset")

func start() -> void:
	if ending:
		return
	visible = true
	tween.reset()
	tween.create(Tween.EASE_OUT,Tween.TRANS_CUBIC,true)
	for part in parts:
		part.position.x = 280 + part.animation_z * 2
		tween.add_attribute("position:x",0,1.5,part)
	emit_signal("move_in")

func flash() -> void:
	if ending:
		return
	tween.create(Tween.EASE_OUT,Tween.TRANS_CUBIC,true)
	tween.set_ignore_pause_mode()
	for n in names:
		n.visible = true
	for part in parts:
		part.modulate = Color(11,11,11,1)
		tween.add_attribute("modulate",Color.white,1.15,part)
	emit_signal("color",current_weapon)

func bars_expand() -> void:
	tween.create(Tween.EASE_OUT,Tween.TRANS_CUBIC,true)
	tween.add_attribute("modulate:a",0.0,0.5,fullblack)
	tween.add_attribute("position:y",bar.position.y +40,0.5,bar)
	tween.add_attribute("position:y",bar2.position.y -39,0.5,bar2)
	tween.add_attribute("scale:y",1.0,0.5,green_bg)
	emit_signal("start")

var fading_out := false

func fadeout(duration := 1.0):
	print("called fadeout")
	if not fading_out:
		print("starting fadeout")
		tween.create(Tween.EASE_OUT,Tween.TRANS_LINEAR,true)
		tween.set_ignore_pause_mode()
		tween.add_attribute("modulate:a",1.0,duration,fullblack)
		tween.add_attribute("volume_db",-40,duration,audio)
		tween.add_callback("end",self,[duration + .5])
		fading_out = true

func move_things_away():
	if ending:
		return
	tween.create(Tween.EASE_OUT,Tween.TRANS_LINEAR,true)
	tween.set_ignore_pause_mode()
	tween.add_attribute("position:y",bar.position.y -256,0.8,bar)
	tween.add_attribute("position:y",bar2.position.y -256,0.8,bar2)
	tween.add_attribute("position:y",green_bg.position.y -256,0.8,green_bg)
	tween.add_attribute("position:x",position.x -256,0.75,self)
	tween.add_attribute("position:x",text.position.x +156,0.5,text)
	#tween.add_attribute("rect_position:x",weapon_name.rect_position.x +156,0.5,weapon_name)

func end(wait_time := 1.0):
	Tools.timer(wait_time,"go_to_stage_select",GameManager)
