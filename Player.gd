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
var can_grapple := true

var hook_points : Array

var hp setget _set_hp
export var max_hp = 3
export var iframes = false

var falling := false
var true_falling := false
var safe_position : Vector2

func _ready():
#	$IndicatorLines.set_as_toplevel(true)
#	$IndicatorLines/Line2D.points.resize(0)
	indicator_line = $IndicatorLines/Line2D.duplicate()
#	$IndicatorLines/Line2D.queue_free()
	
	$GrappleChain.visible = false
	$GrappleChain.set_as_toplevel(true)
	
	self.hp = max_hp
	
	$Sprite.animation = "default"


func _physics_process(delta):
#	$IndicatorLines.global_position = global_position
	
	if !falling:
		safe_position = global_position
		$Sprite.animation = "default"
		$SweatParticles.emitting = false
	else:
		$Sprite.animation = "sweat"
		$SweatParticles.emitting = true
	
	if Input.is_action_just_pressed("RESTART"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("EXIT"):
		get_tree().quit()
	
	if (falling && velocity.length() > 550) || grappling:
		$FallTimer.paused = true
	else:
		$FallTimer.paused = false
		
	if true_falling:
		$SweatParticles.emitting = false
		rotate(0.3)
		scale.x = lerp(scale.x, 0.1, 0.03)
		scale.y = lerp(scale.y, 0.1, 0.03)
		if scale.x < 0.2:
			falling = false
			true_falling = false
			global_position = safe_position
			scale.x = 1
			scale.y = 1
			rotation = 0
			velocity = Vector2.ZERO
			self.hp -= 1
			clear_hookprojectile_points()
	else:
		if Input.is_action_just_pressed("LEFT_CLICK") && !Input.is_action_pressed("RIGHT_CLICK"):
			$AnimationPlayer.play("Fire")
			var new_hook_projectile : HookProjectile = hook_projectile.instance()
			var projectile_direction = global_position.direction_to(get_global_mouse_position())
			
			new_hook_projectile.direction = projectile_direction
			new_hook_projectile.global_position = global_position
			new_hook_projectile.connect("wall_hit", self, "_add_hookprojectile_point_wall")
			new_hook_projectile.connect("object_hit", self, "_add_hookprojectile_point_object")
			new_hook_projectile.connect("failed", self, "_hookprojectile_failed")
			
			get_parent().add_child(new_hook_projectile)
			if hook_points.size() >= 1:
				can_grapple = false
			
		
		# Movement
		velocity = lerp(velocity, Vector2.ZERO, friction)
		var direction = Vector2.ZERO
		if free_movement:
			direction.x = Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT")
			direction.y = Input.get_action_strength("DOWN") - Input.get_action_strength("UP")
		direction = direction.normalized()
		
		if direction.x < 0:
			$Sprite.flip_h = true
		elif direction.x > 0:
			$Sprite.flip_h = false
		if !$AnimationPlayer.is_playing():
			if direction == Vector2.ZERO:
				$AnimationPlayer.play("Idle")
			else:
				$AnimationPlayer.play("Run")
		
		direction *= speed
		
		if Input.is_action_pressed("RIGHT_CLICK"):
			if hook_points.size() > 0:
				$AnimationPlayer.play("Fire")
			if hook_points.size() > 0 && $ReelNoise.playing == false:
				$ReelNoise.playing = true
			if can_grapple && hook_points.size() == 1:
				# GRAPPLE TO WALLS/OBJECTS
				if hook_points[0].immobile:
					free_movement = false
					grappling = true
					direction = global_position.direction_to(hook_points[0].global_position)
					direction *= grappling_speed
				else:
					hook_points[0].activate()
				if hook_points.size() == 1:
					$GrappleChain.visible = true
					$GrappleChain.points[0] = global_position + Vector2(0, 16)
					$GrappleChain.points[1] = hook_points[0].global_position
			elif hook_points.size() > 1:
				# GRAPPLE TWO OBJECTS TOGETHER
				for hook in hook_points:
					hook.activate()
		elif Input.is_action_just_released("RIGHT_CLICK"):
			$ReelNoise.playing = false
			if grappling:
				free_movement = true
				grappling = false
			$GrappleChain.visible = false
			clear_hookprojectile_points()
		elif Input.is_action_pressed("RELOAD"):
			clear_hookprojectile_points()
		
		velocity = move_and_slide(velocity + direction)
	
	update_hookprojectile_points()
	
#	if Input.is_action_just_pressed("ui_accept"):
#		#TEMP
#		$CollisionShape2D.set_deferred("disabled", !$CollisionShape2D.disabled)

func _add_hookprojectile_point_wall(point : Vector2):
	var new_hook_point : HookPoint = hook_point.instance()
	new_hook_point.global_position = point
	new_hook_point.immobile = true
	new_hook_point.player = self
	new_hook_point.connect("hook_destroyed", self, "remove_hookpoint")
	if hook_points.size() != 0:
		new_hook_point.previous_point = hook_points.back()
		hook_points.back().next_point = new_hook_point
	hook_points.append(new_hook_point)
	get_parent().add_child(new_hook_point)
	
	if hook_points.size() > 1:
		can_grapple = false
	
#	var new_indicator_line = indicator_line.duplicate()
#	$IndicatorLines.add_child(new_indicator_line.duplicate())

func _add_hookprojectile_point_object(object):
	for hook in hook_points:
		if hook.attached_object == object: return
	
	var new_hook_point : HookPoint = hook_point.instance()
	new_hook_point.attached_object = object
	new_hook_point.immobile = false
	new_hook_point.player = self
	new_hook_point.connect("hook_destroyed", self, "remove_hookpoint")
	if hook_points.size() != 0:
		new_hook_point.previous_point = hook_points.back()
		hook_points.back().next_point = new_hook_point
	
	hook_points.append(new_hook_point)
	get_parent().add_child(new_hook_point)
	
	if hook_points.size() > 1:
		can_grapple = false
	
	var new_indicator_line = indicator_line.duplicate()
	$IndicatorLines.add_child(new_indicator_line.duplicate())

func clear_hookprojectile_points():
	for line in $IndicatorLines.get_children():
		line.queue_free()
	var hooks = hook_points.duplicate()
	hook_points.resize(0)
	for hook in hooks:
		hook.destroy()
	
	can_grapple = true

func update_hookprojectile_points():
#	if hook_points.empty(): return
	
	# Erase existing lines
	var lines = $IndicatorLines.get_children()
	for line in lines:
		line.queue_free()
	
	# Create new lines
	if Input.is_action_pressed("RIGHT_CLICK"):
		return
	var i = 0
	for hookpoint in hook_points:
		var new_indicator_line : Line2D = indicator_line.duplicate()
#		new_indicator_line.points.append(Vector2.ZERO)
#		new_indicator_line.points.append(Vector2.ZERO)
		new_indicator_line.points[0] = Vector2(0, 16)
		new_indicator_line.points[1] = to_local(hook_points[i].global_position)
#		new_indicator_line.points.push_back(global_position + Vector2(0, 16))
#		new_indicator_line.points.push_back(hook_points[i].global_position)
#		print(new_indicator_line.points)
#		$IndicatorLines.call_deferred("add_child", new_indicator_line)
		$IndicatorLines.add_child(new_indicator_line)
		i += 1

func remove_hookpoint(hookpoint):
	var idx = hook_points.find(hookpoint)
	if idx != -1:
		if idx-1 >= 0:
			if idx+1 < hook_points.size():
				hook_points[idx-1].next_point = hook_points[idx+1]
			else:
				hook_points[idx-1].next_point = null
		if idx+1 < hook_points.size():
			if idx-1 >= 0:
				hook_points[idx+1].previous_point = hook_points[idx-1]
			else:
				hook_points[idx+1].next_point = null
	hook_points.erase(hookpoint)
	if hook_points.size() == 1:
		hook_points[0].destroy()
	if hook_points.empty():
		$GrappleChain.visible = false
		$ReelNoise.playing = false


func _on_EnemyDetector_body_entered(body):
	if body.harmful:
		self.hp -= 1


func _on_PitDetector_body_entered(body):
	falling = true
	$FallTimer.start(0.2)

func _on_PitDetector_body_exited(body):
	if !true_falling:
		$FallTimer.stop()
		falling = false
		true_falling = false


func _on_FallTimer_timeout():
	true_falling = true
	clear_hookprojectile_points()

var hitsound = preload("res://HitSound.tscn")
func _set_hp(new):
	if iframes:
		return
	
	hp = new
	$CanvasLayer/HP.text = "health: " + str(hp)
	if new == max_hp:
		return
	
	if hp <= 0:
		get_tree().reload_current_scene()
	else:
		iframes = true
#		$IFrameTimer.start()
		$EffectPlayer.play("Blink")
	var new_hitsound = hitsound.instance()
	get_parent().add_child(new_hitsound)

	
func _hookprojectile_failed():
	clear_hookprojectile_points()
