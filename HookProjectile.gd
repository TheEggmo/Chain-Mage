class_name HookProjectile
extends Node2D

signal wall_hit
signal object_hit
signal failed

var direction : Vector2
export var speed = 1000

export var lifetime := 1.0

var hooksound = preload("res://HookProjectileSound.tscn")

func _ready():
	$Timer.start(lifetime)
	var new_hooksound = hooksound.instance()
	get_parent().add_child(new_hooksound)

func _physics_process(delta):
	global_position += direction * speed * delta
	
	rotate(.01)
	
	modulate.a = $Timer.time_left/lifetime


func _on_WallDetector_body_entered(body):
	emit_signal("wall_hit", global_position)
	direction = Vector2.ZERO
	destroy()

var triggered := false
var blinksound = preload("res://BlinkSound.tscn")
func _on_ObjectDetector_body_entered(body):
	if triggered:
		return
	triggered = true
	if body.boss && body.phase != 1:
		var new_sound = blinksound.instance()
		get_parent().add_child(new_sound)
		emit_signal("failed")
		destroy()
		return
	emit_signal("object_hit", body)
	destroy()


func _on_Timer_timeout():
	destroy()

func destroy():
	queue_free()
