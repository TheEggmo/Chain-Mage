extends Node

var hook_points : PoolVector2Array

var root = get_tree().get_root()

#func add_hookprojectile_point(point : Vector2):
#	hook_points.append(point)
##	var new_indicator_line = indicator_line.duplicate()
##	$IndicatorLines.add_child(new_indicator_line.duplicate())
#
#func clear_hookprojectile_points():
#	hook_points.resize(0)
#	for line in $IndicatorLines.get_children():
#		line.queue_free()
#
#func update_hookprojectile_points():
#	if hook_points.empty(): return
#
#	var i = 0
#	for line in $IndicatorLines.get_children():
#		line.points[0] = global_position
#		line.points[1] = hook_points[i]
#		i += 1
