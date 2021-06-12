extends KinematicBody2D

var player : KinematicBody2D = null

var velocity : Vector2
var speed = 25
var friction = 0.1

var direction := Vector2.ZERO

var free_movement := true setget _set_free_movement
var falling := false

func _physics_process(delta):
	if falling && velocity.length() < 300:
		rotate(0.1)
		scale.x = lerp(scale.x, 0.1, 0.01)
		scale.y = lerp(scale.y, 0.1, 0.01)
		if scale.x < 0.2:
			destroy()
	else:
		if free_movement:
			direction = Vector2.ZERO
			velocity = lerp(velocity, Vector2.ZERO, friction)
	#		if player:
	#			direction = global_position.direction_to(player.global_position)
			direction *= speed
			velocity = move_and_slide(velocity + direction)
		else:
			move_and_slide(velocity + direction)
	#		velocity = lerp(velocity, Vector2.ZERO, friction*0.2)
	velocity = velocity.clamped(1000)


func _on_Area2D_body_entered(body):
	if body == self || body.falling: 
		return
	print("enemy collision")
	if !free_movement || !body.free_movement:
		destroy()
		body.destroy()
		

func _set_free_movement(value):
	if value == false && free_movement == true:
		velocity = Vector2.ZERO
	free_movement = value
	
#	$Area2D.set_deferred("monitoring", !value)


var death_particles = preload("res://DeathParticles.tscn")
func destroy():
	var new_death_particles = death_particles.instance()
	new_death_particles.global_position = global_position
	new_death_particles.modulate = Color8(121, 65, 0, 255)
	if falling:
		new_death_particles.scale = scale * 2
	get_tree().get_root().add_child(new_death_particles)
	queue_free()

func _on_PitDetector_body_entered(body):
	falling = true
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("monitoring", false)


func _on_PitDetector_body_exited(body):
	falling = false
	$CollisionShape2D.set_deferred("disabled", false)
	$Area2D/CollisionShape2D.set_deferred("monitoring", true)
