extends "res://scenes/weapons/_base/_BaseProjectile.gd"


const DUMMY_B = preload("res://scenes/main/levels proper/0_tutorial/DummyB.gd")
signal cleared


func init_travel(pos, dir) -> void:
	.init_travel(pos, dir)
	connect("cleared", _level_node.get_node("Access/HintC"), "on_bullet_clear")


func _on_Projectile_body_entered(body: Node) -> void:
	if body is DUMMY_B:
		return
	._on_Projectile_body_entered(body)
