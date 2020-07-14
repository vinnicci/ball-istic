extends "res://scenes/bots/_ais/charger ai/ChargerAI.gd"


func _on_DetectionRange_body_exited(body: Node) -> void:
	if body != _enemy && _enemies.has(body) == true:
		_enemies.erase(body)
	if body == _enemy:
		_enemy = null


var _exploded: bool = false


func _special() -> void:
	if _exploded == false:
		_parent_node.take_damage(100, Vector2(0,0))
		_exploded = true
