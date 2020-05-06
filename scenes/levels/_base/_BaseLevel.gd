extends Node2D

#Nav node: attach tilemaps/static bodies with nav mesh and collision
#Bots node: attach bots
var _is_player_dead: bool = false
var _init_cam: bool = false


func _ready() -> void:
	Global.current_level = self
	for bot in $Bots.get_children():
		if bot is Global.CLASS_PLAYER:
			Global.player = bot
			break


func _process(delta: float) -> void:
	if _init_cam == true:
		return
	if is_instance_valid(Global.player) == true && Global.player.is_alive() == false:
		$Camera2D.global_position = Global.player.global_position
		$Camera2D.current = true
		_init_cam = true
	if is_instance_valid(Global.player) == false:
		$Camera2D.current = true
		_init_cam = true


func spawn_projectiles(projectile, proj_position: Vector2, proj_direction: float, origin: bool) -> void:
	add_child(projectile)
	projectile.init_travel(proj_position, proj_direction, origin)


func get_points(start: Vector2, end: Vector2) -> Array:
	var points: Array = $Nav.get_simple_path(start, end)
	return points
