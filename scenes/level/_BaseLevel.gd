extends Node2D


#add bot instances in Bots node
func _ready() -> void:
	for child_node in $Bots.get_children():
		child_node.connect("shooting", self, "_on_shoot")


func _on_shoot(projectiles, proj_position, proj_direction, hostile_proj) -> void:
	for projectile in projectiles:
		add_child(projectile)
		projectile.ready_travel(proj_position, proj_direction, hostile_proj)
