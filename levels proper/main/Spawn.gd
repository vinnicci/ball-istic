extends Position2D


onready var _spawn_table: Array = []
var _spawned_bot: Node
var _big_bot: Node
var _level_node: Node


func set_level(level) -> void:
	_level_node = level


func set_big_bot(big_bot) -> void:
	_big_bot = big_bot


func spawn_bot() -> void:
	if (is_instance_valid(_spawned_bot) == true &&
		_spawned_bot.state != Global.CLASS_BOT.State.DEAD):
		return
	if $SpawnTimer.is_stopped() == true:
		$SpawnTimer.start()


func _on_SpawnTimer_timeout() -> void:
	if (is_instance_valid(_level_node.get_player()) == false ||
		is_instance_valid(_big_bot) == false ||
		_big_bot.state == Global.CLASS_BOT.State.DEAD):
		return
	_spawn_table.shuffle()
	_spawned_bot = _spawn_table.front().instance()
	_level_node.add_bot(_spawned_bot)
	_spawned_bot.get_node("AI").engage(_level_node.get_player())
	_spawned_bot.global_position = global_position
