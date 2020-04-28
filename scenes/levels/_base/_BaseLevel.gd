extends Node2D

#Nav node: attach tilemaps/static bodies with nav mesh and collision
#Bots node: attach bots

var is_player_dead: bool = false


func _ready() -> void:
	for child_node in $Bots.get_children():
		if child_node.current_weapon != null:
			child_node.connect("weapon_shot", self, "_on_weapon_shot")
		if child_node.name == "Player":
			Globals.player = child_node


func _process(delta: float) -> void:
	if is_instance_valid(Globals.player) == false && is_player_dead == false:
		$Camera2D.current = true
		is_player_dead == true


func _on_weapon_shot(projectiles, proj_position, proj_direction, origin) -> void:
	for projectile in projectiles:
		add_child(projectile)
		projectile.ready_travel(proj_position, proj_direction, origin)


func get_points(start: Vector2, end: Vector2) -> Array:
	var points: Array = $Nav.get_simple_path(start, end)
	return points
