extends NinePatchRect

onready var hermes_fill: TextureProgress = $hermes_fill
onready var icarus_fill: TextureProgress = $icarus_fill

onready var tween := TweenController.new(self,false)
onready var h_blink: TextureProgress = $hermes_fill/blink
onready var i_blink: TextureProgress = $icarus_fill/blink

var hermes_weapon
var icarus_weapon

func _ready() -> void:
	hide()
	Event.connect("collected",self,"hide_or_show")
	Event.connect("special_activated",self,"activate")
	Event.connect("special_deactivated",self,"deactivate")

func activate(weapon) -> void:
	visible = true
	set_process(true)
	if weapon.name == "XDrive":
		hermes_fill.visible = true
		icarus_fill.visible = false
		hermes_weapon = weapon
	else:
		icarus_fill.visible = true
		hermes_fill.visible = false
		icarus_weapon = weapon

func deactivate(weapon) -> void:
	if weapon.name == "XDrive":
		hermes_fill.visible = false
		h_blink.visible = false
	else:
		icarus_fill.visible = false
		i_blink.visible = false
	
func _process(delta: float) -> void:
	process_blink(delta)
	if is_hermes_special_enabled():
		var value = get_bar_value(hermes_weapon)
		hermes_fill.value = value
		if value >= 43:
			h_blink.visible = true
		else:
			h_blink.visible = false
			
	elif is_icarus_special_enabled():
		var value = get_bar_value(icarus_weapon)
		icarus_fill.value = value
		if value >= 43:
			i_blink.visible = true
		else:
			i_blink.visible = false
	
	else:
		hide()

func is_hermes_special_enabled() -> bool:
	return hermes_weapon and hermes_weapon.active

func is_icarus_special_enabled() -> bool:
	return icarus_weapon and icarus_weapon.active

var blink_timer := 0.0

func process_blink(delta):
	blink_timer += delta *30
	if h_blink.visible:
		h_blink.modulate.a = sin(blink_timer)
	elif i_blink.visible:
		i_blink.modulate.a = sin(blink_timer)

func get_bar_value(current_weapon) -> float:
	return inverse_lerp(0.0,current_weapon.max_ammo,current_weapon.current_ammo) * 43

func hide():
	visible = false
	set_process(false)
	h_blink.visible = false
	i_blink.visible = false

func unhide():
	if get_current_set() == "hermes":
		visible = true
		set_process(true)
		hermes_fill.visible = true
		icarus_fill.visible = false
		i_blink.visible = false
	elif get_current_set() == "icarus" or get_current_set() == "ultimate":
		visible = true
		set_process(true)
		hermes_fill.visible = false
		icarus_fill.visible = true
		h_blink.visible = false
	else:
		visible = false
		pass

func get_current_set() -> String:
	if is_instance_valid(GameManager.player):
		return GameManager.player.is_full_armor()
	return "none"


func _on_WeaponBar_displayed(weapon) -> void:
	if weapon.name == "XDrive" or weapon.name == "GigaCrash":
		hide()
	else:
		unhide()

func hide_or_show(_d) -> void:
	print("Hideorshow")
	call_deferred("check")

func check():
	print(get_current_set())
	if get_current_set() == "hermes" or get_current_set() == "icarus" or get_current_set() == "ultimate":
		unhide()
	else:
		hide()
	

func _on_WeaponBar_hidden() -> void:
	unhide()
