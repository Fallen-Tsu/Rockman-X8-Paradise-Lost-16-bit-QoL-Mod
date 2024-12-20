extends ChargedBuster

export var ball: PackedScene
var current_balls := 0
var enemies_hit : Array

func projectile_setup(dir : int, position : Vector2, _launcher_velocity := 0.0):
	.projectile_setup(dir, position)
	

func create_ball(enemy):
	if current_balls < 3 and enemies_hit.find(enemy) < 0:
		enemies_hit.append(enemies_hit)
		var ball_instance = ball.instance()
		ball_instance.position = position
		ball_instance.position.x += 32 * sign(self.velocity.x)
		get_tree().current_scene.get_node("Objects").call_deferred("add_child",ball_instance,true)
