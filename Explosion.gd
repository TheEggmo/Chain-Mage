extends Area2D

var dying := false


func _physics_process(delta):
	modulate.a = move_toward(modulate.a, 0, 0.02)
	if modulate.a <= 0:
		queue_free()


func _on_Explosion_body_entered(body):
	body.destroy()


func _on_DefuseTimer_timeout():
	set_deferred("monitoring", false)
	$PlayerDetector.set_deferred("monitoring", false)


func _on_PlayerDetector_body_entered(body):
	var dir = global_position.direction_to(body.global_position)
	body.velocity += dir * 3000
