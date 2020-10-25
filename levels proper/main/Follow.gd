extends Area2D


var _level_node: Node


func set_level(lvl: Node) -> void:
	_level_node = lvl


func _on_Follow_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		for bot in _level_node.allies:
			if is_instance_valid(bot) == false || bot is Global.CLASS_PLAYER:
				continue
			bot.get_node("AI").set_master(body)
