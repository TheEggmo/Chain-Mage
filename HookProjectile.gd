class_name HookProjectile
extends Node2D

signal wall_hit
signal object_hit

var direction : Vector2
export var speed = 1000

func _physics_process(delta):
	global_position += direction * speed * delta


func _on_WallDetector_body_entered(body):
	emit_signal("wall_hit", global_position)
	direction = Vector2.ZERO
	destroy()


func _on_ObjectDetector_body_entered(body):
	emit_signal("object_hit", body)
	destroy()


func _on_Timer_timeout():
	destroy()

func destroy():
	queue_free()
