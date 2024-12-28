extends SimplePlayerProjectile

export var ball: PackedScene
var current_balls := 0
var enemies_hit : Array
export var horizontal_velocity = 350
export var vertical_position_range := 1
signal projectile_started


func projectile_setup(dir : int, position : Vector2, _launcher_velocity := 0.0):
	position_setup(position, dir)
	set_horizontal_speed(dir * horizontal_velocity)
	call_deferred("emit_signal","projectile_started")

func create_ball(enemy):
	if current_balls < 3 and enemies_hit.find(enemy) < 0:
		enemies_hit.append(enemies_hit)
		var ball_instance = ball.instance()
		ball_instance.position = position
		ball_instance.position.x += 32 * sign(self.velocity.x)
		get_tree().current_scene.get_node("Objects").call_deferred("add_child",ball_instance,true)

func _OnHit(_target_remaining_HP) -> void: #override
	pass

func _OnDeflect() -> void:
	pass

func position_setup(spawn_point:Vector2, direction:int):
	var x = spawn_point.x 
	var y = spawn_point.y
	position.x = position.x + x * direction
	position.y = position.y + y + int(rand_range(-vertical_position_range,vertical_position_range))
	facing_direction = direction
