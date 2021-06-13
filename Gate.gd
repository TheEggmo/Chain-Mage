extends TileMap

export var inputs_required = 1

var opened := false

func reduce_input():
	inputs_required -= 1
	if inputs_required <= 0:
		opened = true
		print("gate open")

func increase_input():
	inputs_required += 1
	if inputs_required > 0:
		opened = false
		print("gate closed")

func _physics_process(delta):
	if opened:
		set_collision_layer_bit(0, false)
		modulate.a = 0.2
	else:
		set_collision_layer_bit(0, true)
		modulate.a = 1
