extends VBoxContainer

var choosen_weapon : Control
onready var cover_screen: ColorRect = $"../../CoverScreen"

onready var weapons := get_children()
onready var pause: CanvasLayer = $"../.."

func set_weapon(choice : Control) -> void:
	var last_weapon = choosen_weapon
	choosen_weapon = choice
	if last_weapon and choosen_weapon != last_weapon:
		last_weapon._on_focus_exited()

func on_unlock_buttons() -> void:
	call_deferred("give_focus_to_first_weapon")

func give_focus_to_first_weapon() -> void:
	if choosen_weapon:
		choosen_weapon.silent = true
		choosen_weapon.grab_focus()

func set_weapon_as_player_current_weapon() -> void:
	var current_player_weapon
	if GameManager.is_player_in_scene():
		current_player_weapon = GameManager.player.get_current_weapon()
	if current_player_weapon is BossWeapon:
		for weapon in weapons:
			if weapon.weapon_resource == current_player_weapon.weapon:
				set_weapon(weapon)
	else:
		set_weapon(weapons[0])
	

func _ready() -> void:
	var _s = pause.connect("pause_starting",self,"show_weapons")
	_s = pause.connect("unlock_buttons",self,"on_unlock_buttons")

func show_weapons() -> void:
	for weapon in weapons:
		if weapon.name in GameManager.collectibles:
			weapon.visible = true
		elif weapon.name == "Giga Impact":
			if GameManager.is_player_in_scene():
				weapon.visible = GameManager.player.is_full_armor() == "icarus" or GameManager.player.is_full_armor() == "ultimate" 
		elif weapon.name == "X Drive":
			if GameManager.is_player_in_scene():
				weapon.visible = GameManager.player.is_full_armor() == "hermes"
		else:
			weapon.visible = false
	weapons[0].visible = true #Xbuster
	
	set_weapon_as_player_current_weapon()
	if choosen_weapon:
		choosen_weapon.silent = true
		choosen_weapon._on_focus_entered()
