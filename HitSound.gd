extends AudioStreamPlayer


func _on_HitSound_finished():
	queue_free()


func _on_HookProjectileSound_finished():
	pass # Replace with function body.
