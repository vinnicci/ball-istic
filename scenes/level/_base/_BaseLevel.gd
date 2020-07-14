extends Node2D


#Nav node: attach tilemaps/static bodies with nav mesh and collision
#Bots node: attach bots
var _player: Global.CLASS_PLAYER = null setget , get_player
var _doors: Array
var _engaging_player_count: int = 0
var valid_bots: Array
signal moved


func get_player():
	return _player


func _ready() -> void:
	for bot in $Bots.get_children():
		if bot is Global.CLASS_PLAYER:
			_player = bot
		bot.set_level(self)
		add_bot(bot)
	for door in $Doors.get_children():
		_doors.append(door)
	open_doors()


func add_bot(bot) -> void:
	valid_bots.append(bot)
	bot.connect("dead", self, "_on_bot_dead", [bot])


var _doors_closed: bool = false


func set_engaging_player_count(value: bool) -> void:
	if value == true:
		_engaging_player_count += 1
	else:
		_engaging_player_count -= 1
	if _doors_closed == true && _engaging_player_count == 0:
		open_doors()
		_doors_closed = false
	elif _doors_closed == false && _engaging_player_count != 0:
		close_doors()
		_doors_closed = true


func open_doors() -> void:
	for door in _doors:
		door.open()


func close_doors() -> void:
	for door in _doors:
		door.close()


func spawn_projectile(proj, proj_position: Vector2, proj_direction: float,
	shooter_faction: Color) -> void:
	add_child(proj)
	if proj is Global.CLASS_BOT == true:
		add_bot(proj)
	proj.init_travel(proj_position, proj_direction, shooter_faction)


func get_points(start: Vector2, end: Vector2) -> Array:
	var points: Array = $Nav.get_simple_path(start, end)
	return points


func _on_bot_dead(bot) -> void:
	if bot == _player:
		$Camera2D.global_position = _player.global_position
		$Camera2D.current = true
	valid_bots.erase(bot)


#anim effect cleanup -> critical, deflected, stunned, charge and teleport trail
func _on_Anim_finished(anim_name: String, anim_obj: Node) -> void:
	anim_obj.queue_free()
