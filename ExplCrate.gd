extends Obj

func _set_free_movement(value):
	if value == false && free_movement == true:
		velocity = Vector2.ZERO
	free_movement = value
	
#	$Area2D.set_deferred("monitoring", !value)

var explosion = preload("res://Explosion.tscn")
func destroy():
	var new_death_particles = death_particles.instance()
	new_death_particles.global_position = global_position
	new_death_particles.modulate = Color8(151, 9, 9, 255)
	if falling:
		new_death_particles.scale = scale * 2
	get_tree().get_root().get_node("Level/Enemies").add_child(new_death_particles)
	get_tree().get_root().get_node("Level/Enemies").call_deferred("add_child", new_death_particles)
	if !falling:
		var new_explosion = explosion.instance()
		new_explosion.global_position = global_position
		new_explosion.force = velocity
#		get_tree().get_root().get_node("Level/Enemies").add_child(new_explosion)
		get_tree().get_root().get_node("Level/Enemies").call_deferred("add_child", new_explosion)
	emit_signal("on_death")
	queue_free()
