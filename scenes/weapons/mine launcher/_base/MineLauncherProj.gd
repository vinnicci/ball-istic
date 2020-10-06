extends "res://scenes/weapons/_base/_BaseBotProjectile.gd"


func _ready() -> void:
	_lifetime.paused = true


func init_travel(pos: Vector2, dir: float) -> void:
	.init_travel(pos, dir)


var _visibility_dist: int = 350


func _process(delta: float) -> void:
	if (is_instance_valid(_level_node) == false ||
		is_instance_valid(_level_node.get_player()) == false):
		return
	var player = _level_node.get_player()
	var player_pos = player.transform.origin
	if _dying == true || current_faction == player.current_faction:
		modulate.a = 1
		return
	elif global_position.distance_to(player_pos) > _visibility_dist:
		modulate.a = 0
		return
	modulate.a = ((_visibility_dist - global_position.distance_to(player_pos))
		/ _visibility_dist)
