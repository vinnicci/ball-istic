extends "res://scenes/ai/_base/_BaseAI.gd"


#############
# btree tasks
#############


func task_enemy_close(task):
	if is_instance_valid(enemy) == false:
		task.failed()
		return
	if global_position.distance_to(enemy.global_position) <= 500:
		task.succeed()
	else:
		$Rays/VelocityRay.global_rotation = $Rays/TargetRay.global_rotation - deg2rad(180)
		task.failed()


func task_look_dir(task):
	var vector: Vector2
	if $Rays/VelocityRay.is_colliding() == true:
		vector = Vector2(1,0).rotated($Rays/VelocityRay.global_rotation) + Vector2(1,0).rotated($Rays/VelocityRay.get_collision_normal().angle())
		$Rays/VelocityRay.global_rotation = vector.angle()
		task.reset()
	task.succeed()


func task_move(task):
	if is_instance_valid(enemy) == false:
		task.failed()
		return
	parent_node.velocity = Vector2(1,0).rotated($Rays/VelocityRay.global_rotation)
	if global_position.distance_to(enemy.global_position) < 150:
		$Rays/VelocityRay.global_rotation = $Rays/TargetRay.global_rotation - deg2rad(180)
	task.succeed()
