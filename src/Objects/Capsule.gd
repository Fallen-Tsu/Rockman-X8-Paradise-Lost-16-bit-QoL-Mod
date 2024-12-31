extends Node2D

onready var start_area = get_node("area2D")
onready var sprite = get_node("animatedSprite")
onready var particles = $particles2D
onready var glass: CollisionShape2D = $glass/collisionShape2D

export var debug_logs := false
export var armor_part := "icarus_head"
export var dialogue : Resource
export var ultimate_capsule := false

signal lightning

var player
var charge_state := 0
var gave_armor := false
var finished := false
var timer := 0.0
var timer2 := 0.0
var color := Color(0,0,1,0)

func _ready() -> void:
	Event.listen("player_set",self,"call_deferred_got_armor")
	timer = 0.0
	timer2 = 0.0
	charge_state = 0
	finished = false

func call_deferred_got_armor() -> void:
	call_deferred("handle_already_got_armor")

func handle_already_got_armor() -> void:
	if armor_part in GameManager.collectibles:
		finished = true
		call_deferred("disable_glass_collider")
		sprite.play("finished")
		if debug_logs:
			print_debug("Capsule: Player already has " + armor_part)
	
#near capsule
func _on_area2D_body_entered(body: Node) -> void:
	call_deferred("check_start",body)

func check_start(body: Node) -> void:
	if not finished:
		if GameManager.player.is_executing("Ride"):
			return
		if body.is_in_group("Player") and not body.is_in_group("Props"):
			player = body.get_parent()
			if can_interact() and sprite.animation == "idle":
				sprite.play("open")
				$open.play()
				Event.emit_signal("capsule_open")
				#GameManager.stop_character_inputs()
				GameManager.player.cutscene_deactivate()
				GameManager.start_capsule_dialog(dialogue)
				call_deferred("disable_glass_collider")

func disable_glass_collider() -> void:
	glass.disabled = true
	

func can_interact() -> bool:
	return not player.is_executing("Ride") #and not player.is_executing("WeaponStasis")

func _on_area2D2_body_entered(_body: Node) -> void:
	if not finished:
		if can_interact():
			Event.emit_signal("capsule_entered")
			player.force_movement()
			player.play_animation_once("recover")
			player.deactivate()
			player.global_position.x = global_position.x
			player.global_position.y = global_position.y -31
			sprite.play("slow_charge")
			color = Color(0,0,1,0)
			enable_charge_shader()
			particles.emitting = true
			$charge.play()
			charge_state += 1

func _process(delta: float) -> void:
	if not finished:
		if charge_state >= 1:
			timer += delta
			player.animatedSprite.material.set_shader_param("Color", color)
		
		if charge_state >= 1 and charge_state < 3:
			particles.speed_scale += delta * 2
			color = lerp(Color(abs(cos(timer*5000)) * 0.25, 0,  abs(sin(timer*5000))* 0.25, 0), Color(abs(cos(timer*5000)), 0.5,  abs(sin(timer*5000)), 0), timer/5)

		elif charge_state == 3:
			timer2 += delta
			color = lerp(Color(1,1,1,1), Color(0,0,0,0), timer2)
			
		if charge_state == 1:
			if timer > 2:
				sprite.play("fast_charge")
				charge_state += 1

		elif charge_state == 2:
			if timer > 5:
				sprite.play("lightning")
				emit_signal("lightning")
				Event.emit_signal("screenshake",1.0)
				z_index = 5
				$thunder.play()
				particles.emitting = false
				charge_state += 1
				timer = 0
		
		elif charge_state == 3:
			if timer > 0.4:
				if not gave_armor:
					if ultimate_capsule : 
						var parts=["legs","body","arms","head"]
						for part in parts:
							Event.emit_signal("collected","ultimate_"+part)
							player.play_animation_once("armor_receive")
					else : 
						Event.emit_signal("collected", armor_part)
						player.play_animation_once("armor_receive")
					Savefile.save()
					gave_armor = true
					achievement_check()

		elif charge_state == 4:
			if timer > 0.5:
				charge_state += 1
				timer = 0
				timer2 = 0
			
		elif charge_state == 5:
			player.play_animation_once("armor_blink")
			if timer > 1.2:
				player.play_animation_once("victory")
				$victory.play()
				charge_state += 1
				timer = 0
		
		elif charge_state == 6:
			if timer > 1:
				player.stop_forced_movement()
				player.reactivate_charge()
				finished = true

func _on_animatedSprite_animation_finished() -> void:
	if sprite.animation == "open":
		sprite.play("waiting")
	if sprite.animation == "lightning":
		charge_state += 1
		timer = 0
		
	pass # Replace with function body.

func enable_charge_shader():
	player.animatedSprite.material.set_shader_param("Charge", 1)

func disable_charge_shader():
	player.animatedSprite.material.set_shader_param("Charge", 0)

func achievement_check():
	print("Achievements: checking armor parts...")
	
	if "hermes" in armor_part:
		if has_fullset("hermes"):
			Achievements.unlock("COLLECTFULLHERMES")
	elif "ultimate" in armor_part:
		if has_fullset("ultimate"):
			Achievements.unlock("COLLECTFULLULTIMATE")
	else:
		if has_fullset("icarus"):
			Achievements.unlock("COLLECTFULLICARUS")

func has_fullset(set : String) -> bool:
	var pieces = 0
	for collectible in GameManager.collectibles:
		if set in collectible:
			pieces += 1
	return pieces == 4
