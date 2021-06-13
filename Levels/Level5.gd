extends Node2D

export var no_enemies := false

func _ready():
	for enemy in $Enemies.get_children():
		enemy.player = $Player
		enemy.navigation = $Navigation2D
	
	if no_enemies:
		$Enemies.queue_free()
	
	$BG/Label.visible = false

var spawner1 = null
var spawner2 = null
var spawnerpos1 = Vector2(786, -224)
var spawnerpos2 = Vector2(-112, 464)
func _on_GolemBoss_phase_changed(newphase):
#	print(newphase)
	if newphase == 2:
		spawner1 = $Spawner.duplicate()
		spawner2 = $Spawner.duplicate()
		spawner1.global_position = spawnerpos1
		spawner2.global_position = spawnerpos2
		add_child(spawner1)
		add_child(spawner2)
	else:
		if is_instance_valid(spawner1):
			spawner1.destroy()
		if is_instance_valid(spawner2):
			spawner2.destroy()

func _on_GolemBoss_on_death():
	$BG/Label.visible = true
