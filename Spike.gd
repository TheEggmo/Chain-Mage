extends Area2D

var player

func _on_Spike_body_entered(body):
	body.destroy()
