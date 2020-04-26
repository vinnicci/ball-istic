extends "res://scenes/ai/_base/_BaseAI.gd"


var backing_off: bool = false


#############
# btree tasks
#############


func task_charge_attack(task):
	if is_instance_valid(enemy) == true && $TargetRay.get_collider() == enemy:
		parent_node.charge($TargetRay.global_rotation)
		backing_off = true
		task.succeed()
	else:
		task.failed()


func task_charge_ready(task):
	if parent_node.timer_charge_cooldown.is_stopped() == true && backing_off == false:
		task.succeed()
	else:
		task.failed()


func task_back_off(task):
	if backing_off == true:
		$VelocityRay.global_rotation = $TargetRay.global_rotation - deg2rad(180)
	elif backing_off == false:
		$VelocityRay.global_rotation = $TargetRay.global_rotation
	parent_node.velocity = Vector2(1,0).rotated($VelocityRay.global_rotation)
	task.succeed()


func _on_BackoffRange_body_entered(body: Node) -> void:
	if enemy != null && body == enemy:
		backing_off = true


func _on_BackoffRange_body_exited(body: Node) -> void:
	if enemy != null && body == enemy:
		backing_off = false
