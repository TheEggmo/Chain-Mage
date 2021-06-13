extends Area2D

var pressed := false setget _set_pressed

var detected_bodies := 0

signal pressed
signal released

func _on_Button_body_entered(body):
	detected_bodies += 1
	if detected_bodies > 0:
		self.pressed = true


func _on_Button_body_exited(body):
	detected_bodies -= 1
	detected_bodies = max(0, detected_bodies)
	
	if detected_bodies <= 0:
		self.pressed = false

func _set_pressed(new):
	if new == pressed:
		return
	
	pressed = new
	
	if pressed:
		emit_signal("pressed")
		print("button pressed")
	else:
		emit_signal("released")
		print("button released")
