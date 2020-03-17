extends "res://scenes/level/_BaseLevel.gd"


func get_points(start: Node, end: Node) -> Array:
	var points: Array = $Navigation2D.get_simple_path(start.global_position, end.global_position)
	return points
