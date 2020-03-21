extends Node2D

#Nav node: attach base tilemap or base static body
#Bots node: attach bot
#add bot instances in Bots node
func _ready() -> void:
	for child_node in $Bots.get_children():
		child_node.connect("shooting", self, "_on_shoot")


func _on_shoot(projectiles, proj_position, proj_direction, hostile_proj) -> void:
	for projectile in projectiles:
		add_child(projectile)
		projectile.ready_travel(proj_position, proj_direction, hostile_proj)


func get_points(start: Node, end: Node) -> Array:
	var points: Array = $Nav.get_simple_path(start.global_position, end.global_position)
	return points
