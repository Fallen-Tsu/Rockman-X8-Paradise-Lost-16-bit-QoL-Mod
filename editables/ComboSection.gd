extends Node2D

const rankings := {"e":0,"d":1,"c":2,"b":3,"a":4,"s":5}

export var debug_logs := false
export var s_time_limit := 40.0

export var s_ranking := 100.0
export var a_ranking := 70.0
export var b_ranking := 50.0
export var c_ranking := 25.0
export var d_ranking := 10.0

var active := false
var enemies_activated := false
var decay := 0.0
var timer := 0.0
var last_hits : Array
var current_combo := 0.0
var current_ranking := "e"
var enemies : Array
onready var player: KinematicBody2D = $"../../X"
onready var visual: Label = $"../../X/combo_label"
onready var visual_ranking: Node2D = $"../../StateCamera/VisualRanking"

const intro = preload("res://src/Sounds/OST - TroiaBase 2 - Intro.ogg")
const loop = preload("res://src/Sounds/OST - TroiaBase 2 - Loop.ogg")

signal started
signal combo_value_changed
signal rank_changed(rank)
signal combo_fill(fill)
signal finish
signal open_doors
signal disabled

var enemies_left_to_kill := 0

func _ready() -> void:
	set_physics_process(false)
	for enemy in get_children():
		if enemy is Enemy:
			enemy.listen("combo_hit",self,"damaged_enemy")
			enemy.listen("zero_health",self,"killed_enemy")
			enemies_left_to_kill += 1
			enemies.append(enemy)
	player.listen("received_damage",self,"damaged_player")
	Event.listen("reached_checkpoint",self,"on_checkpoint")
	Event.listen("moved_player_to_checkpoint",self,"on_checkpoint")
	
	var _c = connect("started",visual_ranking,"start")
	_c = connect("rank_changed",visual_ranking,"set_ranking")
	_c = connect("combo_fill",visual_ranking,"on_fill_bar")
	_c = connect("combo_value_changed",visual_ranking,"react")
	_c = connect("finish",visual_ranking,"finish")
	if not Event.is_connected("player_death",visual_ranking,"on_death"):
		_c = Event.connect("player_death",visual_ranking,"on_death")
	_c = Event.connect("player_death",self,"on_death")
	call_deferred("deactivate_all_enemies")

func prepare() -> void:
	activate_all_enemies()

func activate() -> void:
	set_physics_process(true)
	active = true
	emit_signal("started")
	GameManager.music_player.play_song(loop,intro)
	visual_ranking.call_deferred("set_kills_left",enemies_left_to_kill)

func damaged_enemy(inflicter) -> void:
	if active:
		Log("damaged an enemy")
		var n = correct_name(inflicter.name)
		get_and_add_combo_value(n)
		add_to_hits(n)
		emit_signal("combo_value_changed")
		Log(current_combo)

func killed_enemy() -> void:
	if active:
		Log("Killed an enemy")
		add_combo_value(5)
		enemies_left_to_kill -= 1
		emit_signal("combo_value_changed")
		visual_ranking.set_kills_left(enemies_left_to_kill)
		Log(current_combo)

func damaged_player() -> void:
	if active:
		Log("Player Damaged")
		reduce_combo_value(20)
		reset_decay()
		emit_signal("combo_value_changed")
		Log(current_combo)

func add_combo_value(amount) -> void:
	current_combo += amount
	update_ranking()
	reset_decay()

func reduce_combo_value(amount) -> void:
	current_combo = clamp(current_combo - amount,0.0,999999.0)
	update_ranking()

func update_ranking() -> void:
	if get_ranking() != current_ranking:
		current_ranking = get_ranking()
		emit_signal("rank_changed",current_ranking)

func end() -> void:
	active = false
	set_physics_process(false)
	emit_signal("finish")
	if rankings[current_ranking] >= 4:
		emit_signal("open_doors")
		
		if rankings[current_ranking] == 5:
			Event.emit_signal("got_rank_s",name)
	GameManager.music_player.play_stage_song()
	Log("Ranking: " + get_ranking() + " with a total of " + str(current_combo) + " points.")

func on_death():
	active = false
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	timer += delta
	decay = clamp(decay + delta/2, 0.0, 10.0)
	reduce_combo_value(delta * decay)
	get_percentage_fill_and_emit_signal()
	visual.text = str(enemies_left_to_kill) + " - " + str(current_combo) + "\n" + str(timer)


func get_percentage_fill_and_emit_signal() -> void:
	var percentage = inverse_lerp(get_rank_min_pts(),get_rank_max_pts(),current_combo) * 100
	if current_ranking != "s":
		emit_fill(percentage)
	else:
		var time_left_percentage = (1 - inverse_lerp(0.0, s_time_limit, timer)) * 100
		emit_fill(min(percentage,time_left_percentage))

func get_timer() -> float:
	if timer < s_time_limit:
		return s_time_limit - timer
	else:
		visual_ranking.set_timer_color(Color.lightcoral)
		return abs(timer - s_time_limit)

func on_checkpoint(checkpoint : CheckpointSettings) -> void:
	if checkpoint.id >= get_own_id():
		destroy_all_enemies()
		emit_signal("disabled")

func destroy_all_enemies() -> void:
	Log("destroying all enemies")
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.destroy()

func deactivate_all_enemies() -> void:
	Log("deactivating all enemies")
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.visible = false
			enemy.active = false
			enemy.set_physics_process(false)

func activate_all_enemies() -> void:
	Log("activating all enemies")
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.visible = true
			enemy.active = true
			enemy.set_physics_process(true)
	enemies_activated = true

func get_own_id() -> int:
	print_debug(name.substr(7))
	return name.substr(7).to_int()

func emit_fill(value) -> void:
	emit_signal("combo_fill",value)
	visual_ranking.set_timer(get_timer())

func correct_name(inflicter_name : String) -> String:
	var correct_name := inflicter_name
	while correct_name[correct_name.length() - 1].is_valid_float():
		correct_name.erase(correct_name.length() - 1, 1)
	return correct_name

func get_rank_min_pts() -> float:
	if get(current_ranking + "_ranking") != null:
		return get(current_ranking + "_ranking")
	return 0.0
	
func get_rank_max_pts() -> float:
	if current_ranking == "s":
		return s_ranking * 1.25
	elif current_ranking == "a":
		return s_ranking
	elif current_ranking == "b":
		return a_ranking
	elif current_ranking == "c":
		return b_ranking
	elif current_ranking == "d":
		return c_ranking
	return d_ranking

func reset_decay() -> void:
	decay = 0

func get_and_add_combo_value(inflicter_name) -> void:
	add_combo_value(get_combo_value(correct_name(inflicter_name)) )

func get_combo_value(inflicter_name) -> float:
	var index = last_hits.find(inflicter_name,0)
	if index != -1:
		return index + 1
	return 5.0

func add_to_hits(inflicter_name) -> void:
	last_hits.push_front(inflicter_name)
	if last_hits.size() > 5:
		last_hits.pop_back()

func get_ranking() -> String:
	if current_combo >= s_ranking and enemies_left_to_kill <= 0 and timer < s_time_limit:
		return "s"
	elif current_combo >= a_ranking:
		return "a"
	elif current_combo >= b_ranking:
		return "b"
	elif current_combo >= c_ranking:
		return "c"
	elif current_combo >= d_ranking:
		return "d"
	return "e"

func Log(message) -> void:
	if debug_logs:
		print(name + ": " + str(message))


func _on_finish_line_body_entered(_body: Node) -> void:
	if active:
		end()

func start() -> void:
	if not enemies_activated:
		activate_all_enemies()
	activate()
