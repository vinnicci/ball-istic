extends "res://scenes/weapons/_base/_BaseBotProjectile.gd"


func _ready() -> void:
	_lifetime.paused = true


func init_travel(pos: Vector2, dir: float) -> void:
	.init_travel(pos, dir)


var _visibility_dist: int = 350


func _process(delta: float) -> void:
	var player = _level_node.get_player()
	if is_instance_valid(player) == false:
		return
	if _dying == true || current_faction == player.current_faction:
		modulate.a = 1
		return
	elif global_position.distance_to(player.global_position) > _visibility_dist:
		modulate.a = 0
		return
	modulate.a = ((_visibility_dist - global_position.distance_to(player.global_position))
		/ _visibility_dist)
