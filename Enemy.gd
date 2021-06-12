extends Obj

var direction := Vector2.ZERO

func _physics_process(delta):
	if falling && velocity.length() < 300 && !attached:
		fall()
	else:
		if free_movement:
			direction = Vector2.ZERO
			velocity = lerp(velocity, Vector2.ZERO, friction)
			if player:
				direction = global_position.direction_to(player.global_position)
			direction *= speed
			velocity = move_and_slide(velocity + direction)
		else:
			velocity = move_and_slide(velocity)
	velocity = velocity.clamped(1000)
