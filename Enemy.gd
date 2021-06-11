extends KinematicBody2D

var player : KinematicBody2D = null

var velocity : Vector2
var speed = 25
var friction = 0.1

var direction := Vector2.ZERO

var free_movement := true

func _physics_process(delta):
	if free_movement:
		direction = Vector2.ZERO
		velocity = lerp(velocity, Vector2.ZERO, friction)
		if player:
			direction = global_position.direction_to(player.global_position)
		direction *= speed
	velocity = move_and_slide(velocity + direction)
#	velocity = velocity.clamped(100)


func _on_Area2D_body_entered(body):
	print("enemy collision")
	if !free_movement:
		queue_free()
