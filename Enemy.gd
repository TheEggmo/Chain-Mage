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
			
			if direction == Vector2.ZERO:
				$AnimationPlayer.play("Idle")
			else:
				$AnimationPlayer.play("Run")
			
			if direction.x > 0:
				$Sprite.flip_h = false
			elif direction.x < 0:
				$Sprite.flip_h = true
			
			direction *= speed
			velocity = move_and_slide(velocity + direction)
		else:
			velocity = move_and_slide(velocity)
	velocity = velocity.clamped(1000)
