extends Node2D


#Nav node: attach tilemaps/static bodies with nav mesh and collision
#Bots node: attach bots
var _player: Global.CLASS_PLAYER = null setget , get_player


func get_player():
	return _player


func _ready() -> void:
	for bot in $Bots.get_children():
		if bot.has_node("AI"):
			bot.get_node("AI").set_level(self)
		if bot is Global.CLASS_PLAYER:
			_player = bot
		bot.level_node = self
		bot.get_node("Explosion").set_level_cam($Camera2D)


var _init_cam: bool = false


func _process(delta: float) -> void:
	if _init_cam == false && _player != null && _player.state == Global.CLASS_BOT.State.DEAD:
		$Camera2D.global_position = _player.global_position
		$Camera2D.current = true
		_init_cam = true


func spawn_projectile(proj, proj_position: Vector2, proj_direction: float,
	shooter_faction: Color, shooter: Global.CLASS_BOT) -> void:
	add_child(proj)
	var has_explosion: bool = proj.has_node("Explosion")
	if proj is Global.CLASS_PROJ:
		if proj.has_node("ProjBehavior") == true:
			proj.get_node("ProjBehavior").set_level(self)
	if has_explosion == true:
		var explosion_node = proj.get_node("Explosion")
		explosion_node.set_player(_player)
		explosion_node.set_level_cam(get_node("Camera2D"))
	proj.init_travel(proj_position, proj_direction, shooter_faction, shooter)


func get_points(start: Vector2, end: Vector2) -> Array:
	var points: Array = $Nav.get_simple_path(start, end)
	return points


#trail effect cleanup
func _on_Trail_anim_finished(anim_name: String, trail_obj: Node) -> void:
	trail_obj.queue_free()
