extends Area2D

export var damage := 1
var enemies_inside : Array
var time_to_next_damage := 0.0
var damage_time := 0.2
var max_time_on_screen := 3.0
var current_time_on_screen := 0.0
onready var animation_player = $animationPlayer

func _on_PlasmaBall_body_entered(body):
	if body is Enemy and not enemies_inside.has(body):
		enemies_inside.append(body)

func _on_PlasmaBall_body_exited(body):
	if body is Enemy and enemies_inside.has(body):
		enemies_inside.erase(body)


func _physics_process(delta):
	time_to_next_damage += delta
	current_time_on_screen += delta
	if current_time_on_screen > max_time_on_screen:
		animation_player.play("End")
	if time_to_next_damage > damage_time and current_time_on_screen < max_time_on_screen:
		time_to_next_damage = 0.0
		for enemy in enemies_inside:
			if is_instance_valid(enemy):
				enemy.damage(damage,self)
			else:
				enemies_inside.erase(enemy)

func get_facing_direction():
	var dir =  randf()
	return 1 if dir > 0.5 else -1
