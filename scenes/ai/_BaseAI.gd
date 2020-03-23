extends Node2D

#don't forget to set target node on FSM
#recommended to set state names
onready var level_node: = get_parent().get_parent().get_parent()
onready var bot_node: = get_parent()
var targets = []
var target = null
var points: Array
var next_point: Vector2
var in_detection_range: bool = false
var in_line_of_sight: bool = false


func get_points(start: Vector2, end: Vector2) -> void:
	points = []
	if is_instance_valid(target) == false:
		return
	points = level_node.get_points(start, end)
	next_point = points.pop_front()


func get_new_target() -> void:
	if targets.size() != 0:
		target = targets.pop_front()


func _control(delta) -> void:
	if is_instance_valid(target) == false:
		get_new_target()
		return
	$TargetRay.look_at(target.global_position)
	if $TargetRay.get_collider() == target:
		in_line_of_sight = true
	else:
		in_line_of_sight = false


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body.get_parent().name == "Bots" && bot_node.is_hostile != body.is_hostile:
		targets.append(body)
		$TargetRay.enabled = true
		in_detection_range = true
		if target == null:
			target = targets.pop_front()


func _on_DetectionRange_body_exited(body: Node) -> void:
	if body == target:
		$TargetRay.enabled = false
		in_detection_range = false
