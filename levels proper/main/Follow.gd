extends Area2D


var _allies: Array
var _done: bool = false


func set_allies(allies: Array) -> void:
	_allies = allies


func _on_Follow_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER && _done == false:
		for bot in _allies:
			if is_instance_valid(bot) == false || bot is Global.CLASS_PLAYER:
				continue
			bot.get_node("AI").set_master(body)
		_done = true
