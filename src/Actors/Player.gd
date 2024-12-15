extends Character

export var skip_intro := false

var current_armor = ["no_head", "no_body", "no_arms", "no_legs"]
var armor_sprites = []
var flash_timer := 0.0
var block_charging := false
var dashfall := false
var dashjumps_since_jump := 0
var raycast_down : RayCast2D
var colliding := true
var using_upgrades := false
var grabbed := false
onready var lowjumpcast: Label = $lowjumpcast

signal walljump                  
signal wallslide                 
signal dashjump
signal airdash
signal firedash
signal collected_health(amount)  
signal weapon_stasis             
signal end_weapon_stasis         
signal dry_dash                  
signal received_damage           
signal equipped_armor
signal at_max_hp

var ride : Node2D

func deactivate():
	stop_listening_to_inputs()
	stop_charge()
	stop_shot()
	Log ("not active")
	
func activate():
	if is_colliding():
		reactivate_charge()
		.activate()
	
	return

func has_control() -> bool:
	if grabbed:
		return true
	if listening_to_inputs:
		return true
	elif ride:
		return ride.listening_to_inputs
	
	return false

func is_riding() -> bool:
	return is_instance_valid(ride)

func on_land() -> void:
	dashjumps_since_jump = 0
	dashfall = false

func dashjump_signal() -> void:
	emit_signal("dashjump")
	dashjumps_since_jump += 1
	
func airdash_signal() -> void:
	emit_signal("airdash")
	
func firedash_signal() -> void:
	emit_signal("firedash")

func stop_charge():
	for ability in executing_moves:
		if ability.name == "Charge":
			ability.EndAbility()
	block_charging = true
	
func update_facing_direction():
	if direction.x < 0:
		facing_right = false;
		Event.emit_signal("player_faced_left")
	elif direction.x > 0:
		facing_right = true;
		Event.emit_signal("player_faced_right")
	if animatedSprite.scale.x != get_facing_direction():
		animatedSprite.scale.x = get_facing_direction()

func reactivate_charge():
	block_charging = false

func reduce_hitbox():
	collisor.disabled = true

func increase_hitbox():
	collisor.disabled = false
	

func _ready() -> void:
	current_armor = ["no_head", "no_body", "no_arms", "no_legs"]
	Event.listen("collected", self, "equip_parts")
	Event.listen("collected", self, "collect")
	listen("land",self,"on_land")
	
	save_original_colors()
	armor_sprites = get_armor_sprites()
	GameManager.set_player(self)
	Event.call_deferred("emit_signal","player_set")

func get_armor_sprites() -> Array:
	var sprites = []
	for child in animatedSprite.get_children():
		if "armor" in child.name:
			sprites.append(child)
	return sprites

func _process(delta: float) -> void:
	process_flash(delta)

func spike_touch():
	if should_instantly_die() and not is_invulnerable():
		Log("Death by Spikes")
		emit_signal("zero_health")

func lava_touch():
	if should_instantly_die():
		Log("Death by Lava")
		emit_signal("zero_health")

func void_touch():
	Log("Death by falling")
	emit_signal("zero_health")


func should_instantly_die() -> bool:
	return not is_executing("Ride")

func process_flash(delta):
	if flash_timer > 0:
		flash_timer += delta
		if flash_timer > 0.034:
			end_flash()
	
func equip_hermes_head_parts():
	get_node("Charge").charge_time_reduction = 0.25
	get_node("JumpDamage").deactivate()

func equip_hermes_body_parts():
	var dmg = get_node("Damage")
	dmg.damage_reduction = 33 #used to be 25
	dmg.prevent_knockbacks = false
	dmg.conflicting_moves = ["Death", "WallSlide", "Ride"]
	get_node("LifeSteal").activate()

func equip_hermes_arms_parts(): #triple shot
	var cannon = get_node("Shot")
	var hermes_Buster = cannon.get_node("Hermes Buster")
	var icarus_Buster = cannon.get_node("Icarus Buster")
	var altfire = get_node("AltFire")
	
	hermes_Buster.active = true
	icarus_Buster.active = false
	cannon.upgraded = true
	cannon.infinite_charged_ammo = false
	cannon.infinite_regular_ammo = true
	cannon.update_list_of_weapons()
	cannon.set_current_weapon(hermes_Buster)
	altfire.switch_to_hermes()
	#get_node("Charge").level_4_charge = 2.8

func equip_hermes_legs_parts(): #ghost dash
	var dash = get_node("Dash")
	var air_dash = get_node("AirDash")
	var air_jump = get_node("AirJump")
	var fall = get_node("Fall")
	var dashwalljump = get_node("DashWallJump")
	fall.dash_momentum = 210
	dashwalljump.horizontal_velocity = 300
	dash.upgraded = true
	dash.invulnerability_duration = 0.475
	dash.horizontal_velocity = 350
	air_dash.upgraded = true
	air_dash.invulnerability_duration = 0.475
	air_dash.max_airdashes = 2
	air_dash.airdash_count = 2
	air_dash.horizontal_velocity = 375
	air_jump.set_max_air_jumps(0)

func equip_icarus_head_parts():
	get_node("Charge").charge_time_reduction = 0
	get_node("JumpDamage").activate()

func equip_icarus_body_parts():
	var dmg = get_node("Damage")
	dmg.damage_reduction = 50 #used to be 40
	dmg.prevent_knockbacks = true
	dmg.conflicting_moves = ["Death", "Nothing"]
	get_node("LifeSteal").deactivate()

func equip_icarus_arms_parts(): #laser shot
	var cannon = get_node("Shot")
	var icarus_Buster = cannon.get_node("Icarus Buster")
	var hermes_Buster = cannon.get_node("Hermes Buster")
	var altfire = get_node("AltFire")
	icarus_Buster.active = true
	hermes_Buster.active = false
	cannon.upgraded = true
	cannon.infinite_charged_ammo = true
	cannon.infinite_regular_ammo = false
	cannon.update_list_of_weapons()
	cannon.set_current_weapon(icarus_Buster)
	altfire.switch_to_icarus()
	#get_node("Charge").level_4_charge = 3.25

func equip_icarus_legs_parts(): #double jump
	var dash = get_node("Dash")
	var airdash = get_node("AirDash")
	get_node("AirJump").set_max_air_jumps(2)
	var fall = get_node("Fall")
	fall.dash_momentum = 210
	dash.upgraded = false
	dash.dash_duration = 0.55
	dash.invulnerability_duration = 0
	dash.horizontal_velocity = 300
	airdash.upgraded = false
	airdash.max_airdashes = 1
	airdash.horizontal_velocity = 300
	airdash.invulnerability_duration = 0

func is_full_armor() -> String:
	var armor_set := 0
	for piece in current_armor:
		if "hermes" in piece:
			#print("Checking armor: " + piece)
			armor_set += 1
		elif "icarus" in piece:
			armor_set -= 1

	if armor_set == 4:
		return "hermes"
	elif armor_set == -4:
		return "icarus"
	return "no_armor"

func equip_parts(collectible : String):
	if is_armor_part(collectible):
		add_part_to_current_armor(collectible)
		call("equip_" + collectible + "_parts")
		get_node("Armor").display(collectible)
		emit_signal("equipped_armor")
		recover_health(max_health - current_health)
		using_upgrades = true
		
	elif is_heart(collectible):
		equip_heart()
		using_upgrades = true
		
	elif is_subtank(collectible):
		equip_subtank(collectible)
		using_upgrades = true
		
	elif is_weapon(collectible):
		equip_weapon(collectible)

func is_weapon(collectible : String) -> bool:
	return "weapon" in collectible

func equip_weapon(collectible : String) -> void:
	get_node("Shot").unlock_weapon(collectible)
	
func get_current_weapon():
	return get_node("Shot").current_weapon

func is_heart(collectible : String) -> bool:
	return "heart" in collectible or "life" in collectible

func is_subtank(collectible : String) -> bool:
	return "tank" in collectible

func equip_heart():
	GameManager.player.max_health += 2
	GameManager.player.recover_health(2)

func recover_health(value : float):
	if current_health < max_health:
		current_health += value
	if current_health >= max_health:
		emit_signal("at_max_hp")

func equip_subtank(collectible : String):
	for subtank in $Subtanks.get_children():
		if subtank.subtank.id == collectible:
			subtank.activate()

func get_subtank_current_health(id) -> int:
	for subtank in $Subtanks.get_children():
		if subtank.get_id() == id:
			return subtank.current_health
	return -1
	
func add_part_to_current_armor(collectible: String):
	var part_location = collectible.replace("icarus_","").replace("hermes_","")
	for location in current_armor:
		if part_location in location:
			current_armor.remove(current_armor.find(location))
			current_armor.append(collectible)
	GameManager.remove_equip_exception(part_location)

func is_armor_part(collectible : String) -> bool:
	return "icarus" in collectible or "hermes" in collectible

func finished_equipping() -> void:
	get_node("Shot").update_list_of_weapons()

func has_any_upgrades() -> bool:
	return true

func collect(collectible: String):
	GameManager.add_collectible_to_savedata(collectible)

func save_original_colors():
	colors.append(animatedSprite.material.get_shader_param("MainColor1"))
	colors.append(animatedSprite.material.get_shader_param("MainColor2"))
	colors.append(animatedSprite.material.get_shader_param("MainColor3"))
	colors.append(animatedSprite.material.get_shader_param("MainColor4"))
	colors.append(animatedSprite.material.get_shader_param("MainColor5"))
	colors.append(animatedSprite.material.get_shader_param("MainColor6"))

func change_palette(new_colors, paint_armor := true):
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	set_new_colors_on_shader_parameters(animatedSprite,new_colors)
	if paint_armor:
		for sprite in armor_sprites:
			set_new_colors_for_armor_on_shader_parameters(sprite,new_colors)
	else:
		for sprite in armor_sprites:
			set_new_colors_for_armor_on_shader_parameters(sprite,$Armor.BodyColors)
		

func set_new_colors_on_shader_parameters(object,new_colors) -> void:
	object.material.set_shader_param("R_MainColor1", new_colors[0])
	object.material.set_shader_param("R_MainColor2", new_colors[1])
	object.material.set_shader_param("R_MainColor3", new_colors[2])
	object.material.set_shader_param("R_MainColor4", new_colors[3])
	object.material.set_shader_param("R_MainColor5", new_colors[4])
	object.material.set_shader_param("R_MainColor6", new_colors[5])
	
func set_new_colors_for_armor_on_shader_parameters(object,new_colors) -> void:
	object.material.set_shader_param("R_MainColor2", new_colors[1])
	object.material.set_shader_param("R_MainColor3", new_colors[2])

func disable_collision():
	colliding = false
	get_node("CollisionShape2D").set_deferred("disabled",true)
	
func enable_collision():
	colliding = true
	get_node("CollisionShape2D").set_deferred("disabled",false)

func is_colliding() -> bool:
	return colliding

func flash():
	if has_health():
		animatedSprite.material.set_shader_param("Flash", 1)
		flash_timer = 0.01
	
func end_flash():
	animatedSprite.material.set_shader_param("Flash", 0)
	flash_timer = 0

func are_low_walljump_raycasts_active() -> bool:
	var b := true
	for raycast in low_jumpcasts:
		if not raycast.enabled:
			b = false
	return b

func activate_low_walljump_raycasts() -> void:
	for raycast in low_jumpcasts:
		raycast.enabled = true
	lowjumpcast.text = "on"

func deactivate_low_walljump_raycasts() -> void:
	for raycast in low_jumpcasts:
		raycast.enabled = false
	lowjumpcast.text = "off"

func set_global_position(new_position : Vector2) -> void:
	global_position = new_position

func start_dashfall() -> void:
	if not is_on_floor():
		dashfall = true

func set_x(pos) -> void:
	if can_be_moved():
		global_position.x = pos
func set_y(pos) -> void:
	if can_be_moved():
		global_position.y = pos

func move_x(difference) -> void:
	if can_be_moved():
		global_position.x += difference
func move_y(difference) -> void:
	if can_be_moved():
		global_position.y += difference

func can_be_moved() -> bool:
	return not is_executing("Ride")# and is_colliding()

func stop_forced_movement(forcer = null):
	if not is_executing("Ride"):
		emit_signal("stop_forced_movement", forcer)
		grabbed = false
