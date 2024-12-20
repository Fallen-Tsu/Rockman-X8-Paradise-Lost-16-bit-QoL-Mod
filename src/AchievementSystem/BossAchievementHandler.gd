extends Node

export var defeated_any := true
export var perfect_kill := true
export var gigacrush_kill := true

export var _desperation : NodePath
onready var desperation := get_node_or_null(_desperation)

export var no_damage : Resource
export var buster_only : Resource
export var naked : Resource
export var defeated : Resource

var active := false
var taken_damage := false
var damaged_by_special_weapon := false
var has_upgrades := false
var using_desperation := false
var last_hit := "none"
const busters := ["Lemon","Medium","Charged Buster","Laser Buster","Triple Buster","Aux Buster","JumpDamage", "PlasmaShot", "PlasmaBall"]

func _ready() -> void:
	connect_node("Intro","ability_end","start")
	Event.connect("xdrive",self,"on_xdrive")

func start(_d = null) -> void:
	active = true
	GameManager.player.connect("received_damage",self,"damage_check")
	connect_node("Damage","got_hit","buster_check")
	connect_node("BossDeath","screen_flash","fire_achievements")
	connect_desperation()
	print_debug("Achievements: watching " + get_parent().name)
	upgrade_check()

func connect_node(nodename : String, _signal : String, method : String):
	var node = get_node_or_null("../" + nodename)
	if node != null:
		node.connect(_signal,self,method)
	else:
		push_error("Achievements: " + get_parent().name + "'s " + nodename + " not found.")

func connect_desperation() -> void:
	if desperation != null:
		desperation.connect("ability_start",self,"on_desperation")
		desperation.connect("ability_end",self,"on_desperation_end")

func on_desperation(_d = null) -> void:
	using_desperation = true
	
func on_desperation_end(_d = null) -> void:
	using_desperation = false

func on_xdrive() -> void:
	if using_desperation:
		Achievements.unlock("XDRIVEDODGE")

func fire_achievements():
	upgrade_check()
	
	print_debug ("Achievements: Firing achievements...")
	print_debug("Last hit: " + last_hit)
	
	if defeated_any: #able to emit defeated_any
		#Achievements.unlock("DEFEATEDANY") 
		pass #disabled DefeatedAny because it always fired together with buster only
		
	if has_achievement_for(no_damage) and not taken_damage:
		Achievements.unlock(no_damage.get_id())
	
	if has_achievement_for(buster_only) and not damaged_by_special_weapon:
		Achievements.unlock(buster_only.get_id())
	
	if has_achievement_for(naked) and not has_upgrades:
		Achievements.unlock(naked.get_id())

	if perfect_kill: #able to emit perfect_kill
		if not taken_damage and not damaged_by_special_weapon and not has_upgrades:
			Achievements.unlock("PERFECTKILL")
	
	if gigacrush_kill: #able to emit gigacrush_kill
		if last_hit == "GigaCrashCharged":
			Achievements.unlock("GIGACRUSHKILL")
	
	if has_achievement_for(defeated):
		Achievements.unlock(defeated.get_id())
	
func damage_check():
	if not taken_damage:
		taken_damage = true
		print ("Achievements: No Damage disabled.")

func upgrade_check() -> void:
	has_upgrades = GameManager.player.using_upgrades
	if has_upgrades:
		print ("Achievements: Naked disabled.")

func buster_check(inflicter) -> void:
	print ("Achievements: hit by " + inflicter.name)
	last_hit = inflicter.name
	
	for allowed_inflicter in busters:
		if allowed_inflicter in inflicter.name:
			return
	damaged_by_special_weapon = true 
	print ("Achievements: Buster Only disabled.")

func has_achievement_for(element : Resource) -> bool:
	return element != null
