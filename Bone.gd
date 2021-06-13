extends Obj

var direction := Vector2.ZERO

#var dying := false

#func _ready():
#	speed = 350

var prev_position
func _physics_process(delta):
	if dying:
		modulate.a = move_toward(modulate.a, 0, 0.1)
		if modulate.a <= 0:
			queue_free()
	
	if attached:
		rotate(0.03)
		direction = Vector2.ZERO
		if prev_position != global_position:
			$Area2D.set_collision_mask_bit(2, true)
		else:
			$Area2D.set_collision_mask_bit(2, false)
		set_collision_layer_bit(4, false)
	else:
		rotate(0.1)
		global_position += direction * speed * delta
	
	if !attached:
		if direction == Vector2.ZERO:
			dying = true
	
	prev_position = global_position

func _on_SDTimer_timeout():
	dying = true


func _on_Area2D_body_entered(body):
	if body == player:
		return
	else:
		destroy()
		if body.has_method("destroy"):
			body.destroy()


func _on_MaterializeTimer_timeout():
	set_collision_layer_bit(4, true)

func destroy():
	var new_death_particles = death_particles.instance()
	new_death_particles.global_position = global_position
	new_death_particles.scale *= 0.5
	get_tree().get_root().get_node("Level/Enemies").add_child(new_death_particles)

	queue_free()

func _set_falling(new : bool):
	falling = false
