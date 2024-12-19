extends RigidBody2D
onready var projectile: = $".."
export var deflect_particle : NodePath
const break_guards := true

func deflect(_body) -> void:
	if projectile.is_in_group("Player Projectile") and not projectile.name == "PlasmaShot":
		projectile.disable_visual_and_mechanics()
		if deflect_particle:
			get_node(deflect_particle).emit(projectile.facing_direction)

func hit(_d = null) -> void:
	pass
func leave(_d = null) -> void:
	pass

func get_facing_direction() -> int:
	return projectile.get_facing_direction()
