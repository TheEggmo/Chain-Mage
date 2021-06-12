extends Particles2D

func _ready():
	emitting = true
	one_shot = true

func _process(delta):
	if !emitting:
		queue_free()
