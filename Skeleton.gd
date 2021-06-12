extends Obj

var direction := Vector2.ZERO
var fire_direction = Vector2.RIGHT

func _physics_process(delta):
	$RayCast.set_cast_to(to_local(player.global_position))
	
	if falling && velocity.length() < 300 && !attached:
		fall()
	else:
		if free_movement:
			if $RayCast.get_collider() == player:
				$AnimationPlayer.play("Fire")
				fire_direction = global_position.direction_to(player.global_position)
			else:
				$AnimationPlayer.play("Run")
				direction = Vector2.ZERO
				velocity = lerp(velocity, Vector2.ZERO, friction)
				if player:
					direction = global_position.direction_to(player.global_position)
				direction *= speed
				
				if direction.x > 0:
					$AnimatedSprite.flip_h = false
				elif direction.x < 0:
					$AnimatedSprite.flip_h = true
				
				velocity = move_and_slide(velocity + direction)
		else:
			velocity = move_and_slide(velocity)
	velocity = velocity.clamped(1000)

var bone = preload("res://Bone.tscn")
func _fire():
	var new_bone = bone.instance()
	new_bone.global_position = global_position
	new_bone.direction = fire_direction
	get_tree().get_root().add_child(new_bone)
