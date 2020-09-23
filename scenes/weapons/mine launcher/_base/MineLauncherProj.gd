extends "res://scenes/weapons/_base/_BaseBotProjectile.gd"


func _ready() -> void:
	_lifetime.paused = true


func init_travel(pos: Vector2, dir: float) -> void:
	.init_travel(pos, dir)


var _visibility_dist: int = 350


func _process(delta: float) -> void:
	if _dying == true:
		modulate.a = 1
		return
	if is_instance_valid(level_node.get_player()) == false:
		return
	elif global_position.distance_to(level_node.get_player().global_position) > _visibility_dist:
		modulate.a = 0
		return
	if current_faction != level_node.get_player().current_faction:
		modulate.a = ((_visibility_dist - global_position.distance_to(level_node.get_player().global_position))
			/ _visibility_dist)
