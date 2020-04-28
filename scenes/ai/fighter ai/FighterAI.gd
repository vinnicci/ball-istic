extends "res://scenes/ai/_base/_BaseAI.gd"


#############
# btree tasks
#############


func task_seek_enemy(task):
	if is_instance_valid(enemy) == false:
		task.failed()
		return
	if global_position.distance_to(enemy.global_position) < task.get_param(0):
		task.succeed()
	else:
		seek(enemy)
		task.reset()


func task_shoot_enemy(task):
	if is_instance_valid(enemy) == false:
		task.failed()
		return
	parent_node.current_weapon.look_at(enemy.global_position)
	if global_position.distance_to(enemy.global_position) > 800 || parent_node.current_weapon.is_overheating == true:
		if parent_node.roll_mode == false:
			parent_node.switch_mode()
		task.succeed()
	if parent_node.current_weapon.is_overheating == false && $Rays/TargetRay.get_collider() == enemy:
		if parent_node.roll_mode == true:
			parent_node.switch_mode()
		parent_node.shoot_weapon()
		task.reset()


func task_weapon_ready(task):
	if parent_node.current_weapon.current_heat < parent_node.current_weapon.heat_capacity * 0.2:
		task.succeed()
	else:
		task.failed()


func task_charge_mode(task):
	print("charge mode")
	task.succeed()
