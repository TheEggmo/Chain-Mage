extends KinematicBody2D

enum FireMode {GRAPPLE, PULLHOOK}

var hook_projectile = preload("res://HookProjectile.tscn")
var hook_point = preload("res://HookPoint.tscn")
var indicator_line : Line2D

var velocity : Vector2
export var friction = 0.1
export var speed = 50
export var grappling_speed = 150

var free_movement := true
var grappling := false

var hook_points : Array

func _ready():
	$IndicatorLines.set_as_toplevel(true)
	indicator_line = $IndicatorLines/Line2D.duplicate()
	$IndicatorLines/Line2D.queue_free()
	indicator_line.points.resize(0)


func _physics_process(delta):
	if Input.is_action_just_pressed("LEFT_CLICK"):
		var new_hook_projectile : HookProjectile = hook_projectile.instance()
		var projectile_direction = global_position.direction_to(get_global_mouse_position())
		
		new_hook_projectile.direction = projectile_direction
		new_hook_projectile.global_position = global_position
		new_hook_projectile.connect("wall_hit", self, "_add_hookprojectile_point_wall")
		new_hook_projectile.connect("object_hit", self, "_add_hookprojectile_point_object")
		
		get_parent().add_child(new_hook_projectile)
		
	
	# Movement
	velocity = lerp(velocity, Vector2.ZERO, friction)
	var direction = Vector2.ZERO
	if free_movement:
		direction.x = Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT")
		direction.y = Input.get_action_strength("DOWN") - Input.get_action_strength("UP")
	direction *= speed

	if Input.is_action_pressed("RIGHT_CLICK"):
		if hook_points.size() == 1:
#			print("grappling")
			free_movement = false
			grappling = true
			direction = global_position.direction_to(hook_points[0].global_position)
			direction *= grappling_speed
		elif hook_points.size() > 1:
#		elif hook_points.size() == 2:
			for hook in hook_points:
				hook.activate()
	elif Input.is_action_just_released("RIGHT_CLICK"):
		if grappling:
			free_movement = true
			grappling = false
		clear_hookprojectile_points()
	
	velocity = move_and_slide(velocity + direction)
	
	update_hookprojectile_points()

func _add_hookprojectile_point_wall(point : Vector2):
	var new_hook_point : HookPoint = hook_point.instance()
	new_hook_point.global_position = point
	new_hook_point.immobile = true
	new_hook_point.connect("hook_destroyed", self, "remove_hookpoint")
	if hook_points.size() != 0:
		new_hook_point.previous_point = hook_points.back()
		hook_points.back().next_point = new_hook_point
	hook_points.append(new_hook_point)
	get_parent().add_child(new_hook_point)
	
	var new_indicator_line = indicator_line.duplicate()
	$IndicatorLines.add_child(new_indicator_line.duplicate())

func _add_hookprojectile_point_object(object):
	for hook in hook_points:
		if hook.attached_object == object: return
	
	var new_hook_point : HookPoint = hook_point.instance()
	new_hook_point.attached_object = object
	new_hook_point.immobile = false
	new_hook_point.connect("hook_destroyed", self, "remove_hookpoint")
	if hook_points.size() != 0:
		new_hook_point.previous_point = hook_points.back()
		hook_points.back().next_point = new_hook_point
	
	hook_points.append(new_hook_point)
	get_parent().add_child(new_hook_point)
	
	var new_indicator_line = indicator_line.duplicate()
	$IndicatorLines.add_child(new_indicator_line.duplicate())

func clear_hookprojectile_points():
	for line in $IndicatorLines.get_children():
		line.queue_free()
	var hooks = hook_points.duplicate()
	hook_points.resize(0)
	for hook in hooks:
		hook.destroy()

func update_hookprojectile_points():
	if hook_points.empty(): return
	
	var lines = $IndicatorLines.get_children()
	
	var i = 0
#	for line in $IndicatorLines.get_children():
#		if i >= hook_points.size(): line.queue_free()
#		if !is_instance_valid(hook_points[i]): continue
#		line.points[0] = global_position
#		line.points[1] = hook_points[i].global_position
#		i += 1

func remove_hookpoint(hookpoint):
	hook_points.erase(hookpoint)
	print("call")
