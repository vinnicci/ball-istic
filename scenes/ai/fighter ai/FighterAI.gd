extends "res://scenes/ai/_base/_BaseAI.gd"


#############
# btree tasks
#############


func task_weapon_ready(task):
	if parent_node.current_weapon.current_heat < parent_node.current_weapon.heat_capacity * 0.2:
		task.succeed()
	else:
		task.failed()
