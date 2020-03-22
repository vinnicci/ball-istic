extends Node2D

#don't forget to set target node on FSM
#recommended to set state names
onready var level_node: = get_parent().get_parent().get_parent()
onready var bot_node: = get_parent()
var target

var in_detection_range: bool = false
var in_line_of_sight: bool = false


func _control(delta) -> void:
	if is_instance_valid(target) == false:
		return
	$TargetRay.look_at(target.global_position)
	if $TargetRay.get_collider() == target:
		in_line_of_sight = true
	else:
		in_line_of_sight = false


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body.get_parent().name == "Bots" && bot_node.is_hostile != body.is_hostile:
		target = body
		$TargetRay.enabled = true
		in_detection_range = true


func _on_DetectionRange_body_exited(body: Node) -> void:
	if body == target:
		$TargetRay.enabled = false
		in_detection_range = false
