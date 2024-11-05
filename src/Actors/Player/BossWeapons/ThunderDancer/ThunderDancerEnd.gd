extends SimplePlayerProjectile


func _Setup() -> void:
	enable_visuals()
	enable_damage()
	
func enable_visuals() -> void:
	.enable_visuals()
	animatedSprite.playing = true
	animatedSprite.frame = 0

func _OnHit(_target_remaining_HP) -> void: #override
	Log("On hit")
	#disable_visuals()

func _OnDeflect() -> void:
	animatedSprite.speed_scale = 2
	pass
