extends Node2D

#Nav node: attach tilemaps/static bodies with nav mesh and collision
#Bots node: attach bots

var player: WeakRef
var is_player_dead: bool = false


func _ready() -> void:
	for child_node in $Bots.get_children():
		if child_node.current_weapon != null:
			child_node.connect("shooting", self, "_on_shoot")
		if child_node.name == "Player":
			player = weakref(child_node)


func _process(delta: float) -> void:
	if player.get_ref() == null:
		return
	if player.get_ref().is_alive == false && is_player_dead == false:
		$Camera2D.global_position = player.get_ref().global_position
		$Camera2D.current = true
		is_player_dead = true


func _on_shoot(projectiles, proj_position, proj_direction, hostile_proj) -> void:
	for projectile in projectiles:
		add_child(projectile)
		projectile.ready_travel(proj_position, proj_direction, hostile_proj)


func get_points(start: Vector2, end: Vector2) -> Array:
	var points: Array = $Nav.get_simple_path(start, end)
	return points
