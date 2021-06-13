extends Node2D

export var no_enemies := false

func _ready():
	for enemy in $Enemies.get_children():
		enemy.player = $Player
		enemy.navigation = $Navigation2D
	
	if no_enemies:
		$Enemies.queue_free()
