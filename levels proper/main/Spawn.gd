extends Position2D


onready var _spawn_table: Array = []
var _bot: Node
var _level_node: Node


func set_level(level) -> void:
	_level_node = level


func spawn_bot() -> void:
	if (is_instance_valid(_bot) == true &&
		_bot.state != Global.CLASS_BOT.State.DEAD):
		return
	if $SpawnTimer.is_stopped() == true:
		$SpawnTimer.start()


func _on_SpawnTimer_timeout() -> void:
	if (is_instance_valid(_level_node.big_bot) == false ||
		_level_node.big_bot.state == Global.CLASS_BOT.State.DEAD):
		return
	_spawn_table.shuffle()
	_bot = _spawn_table.front().instance()
	_level_node.add_bot(_bot)
	_bot.get_node("AI").engage(_level_node.get_player())
	_bot.global_position = global_position
