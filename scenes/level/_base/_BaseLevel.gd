extends Node2D


#Nav node: attach tilemaps/static bodies with nav mesh and collision
#Bots node: attach bots
var _player: Global.CLASS_PLAYER = null setget , get_player
var _doors: Array
var _engaging_player_count: int = 0


func get_player():
	return _player


func _ready() -> void:
	for bot in $Bots.get_children():
		if bot is Global.CLASS_PLAYER:
			_player = bot
		bot.set_level(self)
	for access in $Access.get_children():
		if access.is_in_group("Doors"):
			_doors.append(access)
	open_doors()


func set_engaging_player_count(value: bool) -> void:
	if value == true:
		_engaging_player_count += 1
	else:
		_engaging_player_count -= 1
	if _engaging_player_count == 0:
		open_doors()
	else:
		close_doors()


func open_doors() -> void:
	for door in _doors:
		door.open()


func close_doors() -> void:
	for door in _doors:
		door.close()


var _init_cam: bool = false


func _process(delta: float) -> void:
	if (_init_cam == false &&
		_player != null && _player.state == Global.CLASS_BOT.State.DEAD):
		$Camera2D.global_position = _player.global_position
		$Camera2D.current = true
		_init_cam = true


func spawn_projectile(proj, proj_position: Vector2, proj_direction: float,
	shooter_faction: Color) -> void:
	add_child(proj)
	proj.init_travel(proj_position, proj_direction, shooter_faction)


func get_points(start: Vector2, end: Vector2) -> Array:
	var points: Array = $Nav.get_simple_path(start, end)
	return points


#trail effect cleanup
func _on_Trail_anim_finished(anim_name: String, trail_obj: Node) -> void:
	trail_obj.queue_free()


#crit effect cleanup
func _on_Crit_anim_finished(anim_name: String, crit_obj: Node) -> void:
	crit_obj.queue_free()
