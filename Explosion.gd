extends Area2D

var dying := false

var force = Vector2.ZERO

func _ready():
	randomize()
	rotation_degrees += stepify(randi()%360, 90)

func _physics_process(delta):
	modulate.a = move_toward(modulate.a, 0, 0.02)
	if modulate.a <= 0:
		queue_free()


func _on_Explosion_body_entered(body):
	body.armor_strength -= 100
	body.destroy()


func _on_DefuseTimer_timeout():
	set_deferred("monitoring", false)
	$PlayerDetector.set_deferred("monitoring", false)


func _on_PlayerDetector_body_entered(body):
	var dir = global_position.direction_to(body.global_position)
	body.velocity += dir * 1 + force * 5
