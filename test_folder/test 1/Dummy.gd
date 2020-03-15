extends "res://scenes/bots/Dummy.gd"


var points: Array
var next_point: Vector2


func get_new_points() -> void:
	var scene_root = get_parent().get_parent()
	points = scene_root.get_points(self, get_parent().get_node("Player"))
	next_point = points.pop_front()


func _control(delta):
	velocity = Vector2(0,0)
	var scene_root = get_parent().get_parent()
	if (global_position - next_point).length() <= 100:
		next_point = points.pop_front()
	if points.size() == 0:
		get_new_points()
	var direction = $Body/WeaponHatch.look_at(next_point)
	velocity = velocity.move_toward(Vector2(1,0).rotated($Body/WeaponHatch.global_rotation), delta)
	
