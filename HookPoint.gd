class_name HookPoint
extends Node2D

var previous_point : HookPoint = null
var next_point : HookPoint = null
var attached_object : KinematicBody2D = null
var immobile := false
var grapple_speed = 500
var activated := false

signal hook_destroyed()

func _ready():
	$Line2D.set_as_toplevel(true)

func _process(delta):
	if is_instance_valid(previous_point):
		$Line2D.visible = true
		$Line2D.points[0] = global_position
		$Line2D.points[1] = previous_point.global_position
	else:
		$Line2D.visible = false

func _physics_process(delta):
	if is_instance_valid(attached_object):
		if activated:
			attached_object.free_movement = false
			attached_object.velocity = Vector2.ZERO
			attached_object.global_position = global_position
#			var dir = attached_object.global_position.direction_to(global_position) * grapple_speed * delta
#			if attached_object.global_position.distance_to(global_position) > 5:
#				attached_object.direction = dir
		else:
			global_position = attached_object.global_position
	elif !immobile:
		destroy()
	
	if activated:
		if is_instance_valid(previous_point) && !previous_point.immobile:
			previous_point.global_position += previous_point.global_position.direction_to(global_position) * grapple_speed * delta
		if is_instance_valid(next_point) && !next_point.immobile:
			next_point.global_position += next_point.global_position.direction_to(global_position) * grapple_speed * delta

func destroy():
	emit_signal("hook_destroyed", self)
	activated = false
	if is_instance_valid(attached_object):
		attached_object.free_movement = true
	queue_free()

func activate():
	activated = true
	
#	if immobile:
#		if previous_point && !previous_point.immobile:
#			previous_point.global_position += previous_point.global_position.direction_to(global_position)
#		if next_point && !next_point.immobile:
#			next_point.global_position += next_point.global_position.direction_to(global_position)
