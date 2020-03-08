extends Node2D

#add bot scenes in Bots node

func _ready() -> void:
	for child_node in $Bots.get_children():
		child_node.connect("shoot", self, "_on_shoot")

func _on_shoot(projectile, proj_position, proj_direction, hostile_proj) -> void:
	add_child(projectile)
	projectile._travel(proj_position, proj_direction, hostile_proj)
