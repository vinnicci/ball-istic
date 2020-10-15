extends "res://scenes/bots/_ais/self destruct ai/SelfDestructAI.gd"


func _on_DetectionRange_body_exited(body: Node) -> void:
	if body != _enemy && _enemies.has(body) == true:
		_enemies.erase(body)
	if body == _enemy:
		_enemy = null
