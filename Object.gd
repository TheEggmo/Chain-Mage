class_name Obj
extends KinematicBody2D

var player : KinematicBody2D = null

var velocity : Vector2
var speed = 25
var friction = 0.1

var navigation : Navigation2D

#var direction := Vector2.ZERO

var free_movement := true setget _set_free_movement
var falling := false setget _set_falling
var true_falling := false

var attached := false

var armored := false
var armor_strength : float = 0 setget _set_armor_strength

signal on_death

func _physics_process(delta):
	if (falling && velocity.length() < 300) || true_falling:
		fall()
	else:
		if free_movement:
			velocity = lerp(velocity, Vector2.ZERO, friction)
			velocity = move_and_slide(velocity)
		else:
			move_and_slide(velocity)
	velocity = velocity.clamped(1000)


func _on_Area2D_body_entered(body):
	if body == self || body.falling: 
		return
	if !free_movement || !body.free_movement:
		if velocity.length() > 300 || body.velocity.length() > 300:
			destroy()
			if body.has_method("destroy"):
				body.destroy()

func _set_free_movement(value):
	if value == false && free_movement == true:
		velocity = Vector2.ZERO
	free_movement = value

func fall():
	true_falling = true
	rotate(0.1)
	scale.x = lerp(scale.x, 0.1, 0.01)
	scale.y = lerp(scale.y, 0.1, 0.01)
	if scale.x < 0.2:
		destroy()

var death_particles = preload("res://DeathParticles.tscn")
func destroy():
	var new_death_particles = death_particles.instance()
	new_death_particles.global_position = global_position
	if falling:
		new_death_particles.scale = scale * 2
	get_tree().get_root().add_child(new_death_particles)
	emit_signal("on_death")
	queue_free()

func _on_PitDetector_body_entered(body):
	falling = true
#	$CollisionShape2D.set_deferred("disabled", true)
	set_collision_layer_bit(2, false)
	$Area2D/CollisionShape2D.set_deferred("monitoring", false)


func _on_PitDetector_body_exited(body):
	falling = false
#	$CollisionShape2D.set_deferred("disabled", false)
	set_collision_layer_bit(2, true)
	$Area2D/CollisionShape2D.set_deferred("monitoring", true)

func _set_falling(new : bool):
	falling = new

func _set_armor_strength(new):
	armor_strength = new
	if armor_strength <= 0:
		armor_break()

func armor_break():
	pass

