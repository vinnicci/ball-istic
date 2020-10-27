extends Area2D


var _allies: Array


func set_allies(allies: Array) -> void:
	_allies = allies


func _on_Follow_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		for bot in _allies:
			if is_instance_valid(bot) == false || bot is Global.CLASS_PLAYER:
				continue
			bot.get_node("AI").set_master(body)
