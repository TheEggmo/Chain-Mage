extends Node2D

export(String, FILE, "*.tscn") var scene
export(String, FILE, "*png") var texture
export var new_scale = 1

onready var object = load(scene)

var spawned_object = null

export var respawn_time := 3.0

func _ready():
	$Timer.start(0.1)
	$Sprite.texture = load(texture)
	$Sprite.scale = Vector2(new_scale, new_scale)

func _physics_process(delta):
	if !is_instance_valid(spawned_object):
		if $Timer.is_stopped():
			$Timer.start(respawn_time)
		$Sprite.modulate.a = .3
	else:
		$Sprite.modulate.a = 0
	

func spawn_object():
	var new_object = object.instance()
	new_object.global_position = global_position
	get_tree().get_root().get_node("Level/Enemies").call_deferred("add_child", new_object)
	spawned_object = new_object
	

func _on_Timer_timeout():
	spawn_object()

func destroy():
	queue_free()
	if is_instance_valid(spawned_object):
		spawned_object.destroy()
