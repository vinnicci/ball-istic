extends Node2D


onready var _parent_node: Area2D = get_parent()


#############
# btree tasks
#############


func task_stop(task):
	_parent_node.proj_velocity = Vector2(0,0)
	task.succeed()


func task_travel(task):
	if _parent_node.is_stopped() == true:
		task.failed()
		return
	_parent_node.proj_velocity = Vector2(_parent_node.speed,0).rotated(_parent_node.rotation)
	task.succeed()


func task_get_target(task):
	pass


func task_homing(task):
	pass


func task_accelerate(task):
	pass


func task_deccelerate(task):
	pass
