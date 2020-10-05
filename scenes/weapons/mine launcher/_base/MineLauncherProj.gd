extends "res://scenes/weapons/_base/_BaseBotProjectile.gd"


func _ready() -> void:
	_lifetime.paused = true


func set_level(new_level) -> void:
	.set_level(new_level)
	_player = _level_node.get_player()


func init_travel(pos: Vector2, dir: float) -> void:
	.init_travel(pos, dir)


var _visibility_dist: int = 350
var _player: Node


func _process(delta: float) -> void:
	if is_instance_valid(_player) == false:
		return
	if _dying == true || current_faction == _player.current_faction:
		modulate.a = 1
		return
	elif global_position.distance_to(_player.global_position) > _visibility_dist:
		modulate.a = 0
		return
	modulate.a = ((_visibility_dist - global_position.distance_to(_player.global_position))
		/ _visibility_dist)
