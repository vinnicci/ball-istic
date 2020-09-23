extends "res://scenes/bots/self destruct/_base/SelfDestructAI.gd"


func _on_DetectionRange_body_exited(body: Node) -> void:
	if body != _enemy && _enemies.has(body) == true:
		_enemies.erase(body)
	if body == _enemy:
		_enemy = null
