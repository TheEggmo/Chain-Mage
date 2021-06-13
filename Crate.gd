extends Obj

func destroy():
	var new_death_particles = death_particles.instance()
	new_death_particles.global_position = global_position
	new_death_particles.modulate = Color8(121, 65, 0, 255)
	if falling:
		new_death_particles.scale = scale * 2
	get_tree().get_root().add_child(new_death_particles)
	emit_signal("on_death")
	queue_free()
