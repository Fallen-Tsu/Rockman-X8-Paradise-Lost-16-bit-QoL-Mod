extends Shot
class_name PrimaryShot

export var upgraded := false
var current_weapon_index := 0
var charge_level := 0
var charged_shot := true
onready var damage: Node2D = $"../Damage"
onready var charge: Node2D = $"../Charge"
onready var chargesound: AudioStreamPlayer = $charge


func _ready() -> void:
	if active:
		Event.listen("charged_shot_release",self,"charged_shot_release")
		Event.listen("weapon_select_left",self,"change_current_weapon_left")
		Event.listen("weapon_select_right",self,"change_current_weapon_right")
		Event.listen("weapon_select_buster",self,"set_buster_as_weapon")
		Event.listen("select_weapon",self,"direct_weapon_select")
		Event.listen("add_to_ammo_reserve",self,"_on_add_to_ammo_reserve")

func charged_shot_release(_charge_level):
	if not character.has_control():
		Log("Couldn't charged fire, character has no control")
		return
	if current_weapon.has_ammo() or current_weapon_is_buster():
		if not current_weapon.is_cooling_down():
			fire_charged(_charge_level)
	elif has_infinite_charged_ammo():
		if current_weapon.name == "GigaCrash":
			if current_weapon.has_ammo():
				fire_charged(_charge_level)
			return
		if not current_weapon_is_buster() and _charge_level < 3:
			return
		if not current_weapon.is_cooling_down():
			fire_charged(_charge_level)

func fire_charged(_charge_level) -> void:
	Log("Firing Charged")
	charge_level = _charge_level
	if executing:
		EndAbility()
	ExecuteOnce()

func _StartCondition() -> bool:
	if current_weapon and character.has_control():
		if current_weapon.name == "XDrive":
			return current_weapon.has_ammo()
		if current_weapon_is_buster():
			return current_weapon.has_ammo()
		elif not current_weapon.is_cooling_down():
			return has_infinite_regular_ammo() or current_weapon.has_ammo()
		else:
			Log("Couldn't fire, either cooling down or character has no control")
			Log("Weapon: " + current_weapon.name + ", cooldown: " + str(current_weapon.timer))
			save_shot()
	return false

func save_shot() -> void:
	if action_just_pressed() and current_weapon.can_buffer:
		if not damage.executing and not current_weapon.last_fired_shot_was_charged:
			Log("Saving fire for next available frame")
			next_shot_ready = true

func manual_save_shot() -> void:
	Log("Saving fire for next available frame manually")
	next_shot_ready = true

func fire (weapon):
	enable_animation_layer()
	restart_animation()
	weapon.fire(charge_level)
	timer = 0.0
	charge_level = 0
	#Log("Fired at " + str(OS.get_ticks_msec()))

func change_current_weapon_left():
	Log("Changing weapon left")
	var index = weapons.find(current_weapon)
	if index -1 < 0:
		set_current_weapon(weapons[weapons.size() - 1])
	else:
		set_current_weapon(weapons[index - 1])
	Log("New weapon: " + current_weapon.name)

func change_current_weapon_right():
	Log("Changing weapon right")
	var index = weapons.find(current_weapon)
	if index +1 > weapons.size() - 1:
		set_current_weapon(weapons[0])
	else:
		set_current_weapon(weapons[index + 1])
	Log("New weapon: " + current_weapon.name)

func set_current_weapon(weapon):
	current_weapon = weapon
	update_character_palette()
	Log("Changed Weapon to " + current_weapon.name)
	Event.emit_signal("changed_weapon", current_weapon)
	next_shot_ready = false

func direct_weapon_select(weapon_resource):
	for weapon in weapons:
		if "weapon" in weapon:
			if weapon.weapon == weapon_resource:
				set_current_weapon(weapon)
				return

func update_character_palette() -> void:
	if not current_weapon:
		set_buster_as_weapon()
	if current_weapon_is_buster() and not "Ultimate" in current_weapon.name:
		character.change_palette(current_weapon.get_palette(),false)
	else:
		character.change_palette(current_weapon.get_palette())

func current_weapon_is_buster() -> bool:
	return "Buster" in current_weapon.name

func get_charged_level():
	if charge.executing:
		charge_level = charge.get_charge_level()
		charge.EndAbility()
		return charge_level
	return 0

func weapon_cooldown_ended(_weapon) -> void:
	if next_shot_ready and character.listening_to_inputs:
		if has_infinite_regular_ammo() or current_weapon.has_ammo():
			Log("Starting saved shot")
			next_shot_ready = false
			if executing:
				EndAbility()
			ExecuteOnce()
	
func unlock_weapon(collectible : String) -> void:
	for child in get_children():
		if child is BossWeapon:
			if child.should_unlock(collectible):
				child.active = true

func _on_add_to_ammo_reserve(amount) -> void:
	var lowest_ammo_weapon

	for weapon in weapons:
		if weapon is BossWeapon:
			if lowest_ammo_weapon:
				if weapon.current_ammo < lowest_ammo_weapon.current_ammo:
					lowest_ammo_weapon = weapon
			else:
				if weapon.current_ammo < 28:
					lowest_ammo_weapon = weapon
	
	if lowest_ammo_weapon:
		lowest_ammo_weapon.increase_ammo(amount)
		if lowest_ammo_weapon != current_weapon:
			chargesound.play()
