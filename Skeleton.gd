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
				
				if fire_direction.x > 0:
					$AnimatedSprite.flip_h = false
				elif fire_direction.x < 0:
					$AnimatedSprite.flip_h = true
			else:
				direction = Vector2.ZERO
				velocity = lerp(velocity, Vector2.ZERO, friction)
				
				var path : PoolVector2Array # path to player
				if is_instance_valid(player) && is_instance_valid(navigation):
					path = navigation.get_simple_path(global_position, player.global_position)
				
				if path: 
					if path[path.size()-1] == player.global_position && path[0] == global_position:
						# CAN reach player
						direction = global_position.direction_to(path[1])
					else:
						# CAN NOT reach player
						direction = Vector2.ZERO
				
				if direction == Vector2.ZERO:
					$AnimationPlayer.play("Idle")
				else:
					$AnimationPlayer.play("Run")
				
				if direction.x > 0:
					$AnimatedSprite.flip_h = false
				elif direction.x < 0:
					$AnimatedSprite.flip_h = true
				
				direction *= speed
				velocity = move_and_slide(velocity + direction)
		else:
			velocity = move_and_slide(velocity)
	velocity = velocity.clamped(1000)

var bone = preload("res://Bone.tscn")
func _fire():
	var new_bone = bone.instance()
	new_bone.global_position = global_position
	new_bone.direction = fire_direction
	get_tree().get_root().get_node("Level/Enemies").add_child(new_bone)
