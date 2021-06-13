extends Area2D

export(String, FILE, "*.tscn") var next_level

func _on_LevelExit_body_entered(body):
	get_tree().change_scene(next_level)
