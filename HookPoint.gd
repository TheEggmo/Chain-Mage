class_name HookPoint
extends Node2D

var player

var previous_point : HookPoint = null
var next_point : HookPoint = null
var attached_object : Obj = null
var immobile := false
var grapple_speed = 1500
var activated := false

signal hook_destroyed()

func _ready():
	if is_instance_valid(attached_object):
		attached_object.attached = true
	$Line2D.set_as_toplevel(true)
	$Line2D.visible = false

func _process(delta):
	if is_instance_valid(previous_point):
		$Line2D.visible = true
		$Line2D.points[0] = global_position
		$Line2D.points[1] = previous_point.global_position
	else:
		$Line2D.visible = false

func _physics_process(delta):
	if is_instance_valid(attached_object):
		if attached_object.falling && attached_object.velocity.length() < 300:
			destroy()
		if activated:
			if !attached_object.armored:
				attached_object.free_movement = false
				var dir = attached_object.global_position.direction_to(global_position) * grapple_speed * delta
				if attached_object.global_position.distance_to(global_position) > 5:
					attached_object.velocity += dir
				global_position = attached_object.global_position
			else:
				global_position = attached_object.global_position
				attached_object.armor_strength -= 0.5
				if attached_object.armor_strength <= 0:
					destroy()
		else:
			global_position = attached_object.global_position
	elif !immobile:
		destroy()
	
	if activated:
		if is_instance_valid(previous_point) && !previous_point.immobile:
			previous_point.global_position += previous_point.global_position.direction_to(global_position) * grapple_speed * delta
		if is_instance_valid(next_point) && !next_point.immobile:
			next_point.global_position += next_point.global_position.direction_to(global_position) * grapple_speed * delta
			
		if !is_instance_valid(previous_point) && !is_instance_valid(next_point) && !attached_object.armored:
			global_position += global_position.direction_to(player.global_position) * grapple_speed * delta

var death_particles = preload("res://DeathParticles.tscn")
func destroy():
	var new_death_particles = death_particles.instance()
	new_death_particles.global_position = global_position
	new_death_particles.modulate = modulate
	get_tree().get_root().add_child(new_death_particles)
	
	emit_signal("hook_destroyed", self)
	activated = false
	if is_instance_valid(attached_object):
		attached_object.free_movement = true
		attached_object.attached = false
		if attached_object.get_collision_layer_bit(4):
			attached_object.destroy()
	queue_free()

func activate():
	activated = true
	
	var immobile_neighbours = 0
	if is_instance_valid(previous_point) && previous_point.immobile:
		immobile_neighbours += 1
	if is_instance_valid(next_point) && next_point.immobile:
		immobile_neighbours += 1
	
	if immobile_neighbours == 2:
		modulate = Color(1, 0, 0)
	elif immobile_neighbours == 1:
		modulate = Color(1, 1, 0)
	else:
		modulate = Color(1, 1, 1)
