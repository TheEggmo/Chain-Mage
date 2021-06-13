extends Obj

var direction := Vector2.ZERO

func _ready():
	armored = true
	armor_strength = 100
	speed = 10

func _physics_process(delta):
	if falling && velocity.length() < 300 && !attached:
		fall()
	else:
		if free_movement:
			direction = Vector2.ZERO
			velocity = lerp(velocity, Vector2.ZERO, friction)
			var path : PoolVector2Array # path to player
			if is_instance_valid(player) && is_instance_valid(navigation):
				path = navigation.get_simple_path(global_position, player.global_position)
			
			if path: 
#				print(path_to_player)
				if path[path.size()-1] == player.global_position && path[0] == global_position:
					# CAN reach player
					direction = global_position.direction_to(path[1])
				else:
					# CAN NOT reach player
					direction = Vector2.ZERO
			
			if direction == Vector2.ZERO:
				$AnimationPlayer.play("Idle")
			else:
				$AnimationPlayer.play("Run")
			
			if direction.x > 0:
				$Sprite.flip_h = false
			elif direction.x < 0:
				$Sprite.flip_h = true
			
			direction *= speed
			velocity = move_and_slide(velocity + direction)
		else:
			velocity = move_and_slide(velocity)
	velocity = velocity.clamped(1000)

func armor_break():
	if dying:
		return
	$Chestplate.visible = false
	var new_death_particles = death_particles.instance()
	new_death_particles.global_position = global_position
	new_death_particles.modulate = Color.gray
	get_tree().get_root().get_node("Level/Enemies").add_child(new_death_particles)
	armored = false
	if is_instance_valid(get_node_or_null("Creaking")):
		$Creaking.queue_free()
	$ArmorBreak.play()

func _set_armor_strength(new):
	armor_strength = new
	if armor_strength <= 0:
		armor_break()
	$Particles2D.emitting = true
	if get_node_or_null("Creaking"):
		if !$Creaking.playing:
			$Creaking.playing = true

func destroy():
	if armor_strength > 0:
		self.armor_strength -= 100
		return
	if dying:
		return
	dying = true
	var new_death_particles = death_particles.instance()
	new_death_particles.global_position = global_position
	new_death_particles.modulate = Color.brown
	if falling:
		new_death_particles.scale = scale * 2
	get_tree().get_root().get_node("Level/Enemies").add_child(new_death_particles)
	emit_signal("on_death")
	play_deathsound()
	queue_free()
