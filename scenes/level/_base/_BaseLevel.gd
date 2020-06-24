extends Node2D


#Nav node: attach tilemaps/static bodies with nav mesh and collision
#Bots node: attach bots
var _init_cam: bool = false
var _player: Global.CLASS_PLAYER = null setget , get_player


func get_player():
	return _player


func _ready() -> void:
	for bot in $Bots.get_children():
		bot.level_node = self
		if bot.has_node("AI"):
			bot.get_node("AI").set_level(self)
		if bot is Global.CLASS_PLAYER:
			_player = bot


func _process(delta: float) -> void:
	if _init_cam == false && _player != null && _player.state == Global.CLASS_BOT.State.DEAD:
		$Camera2D.global_position = _player.global_position
		$Camera2D.current = true
		_init_cam = true


func spawn_projectile(projectile, proj_position: Vector2, proj_direction: float,
	shooter_faction: Color, shooter: Global.CLASS_BOT) -> void:
	add_child(projectile)
	if shooter == null:
		projectile.level_node = self
	projectile.init_travel(proj_position, proj_direction, shooter_faction, shooter)


func get_points(start: Vector2, end: Vector2) -> Array:
	var points: Array = $Nav.get_simple_path(start, end)
	return points


#trail effect cleanup
func _on_Trail_anim_finished(anim_name: String, trail_obj: Node) -> void:
	trail_obj.queue_free()
