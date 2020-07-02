extends "res://scenes/weapons/_base/_BaseWeapon.gd"


var _proj: PackedScene = preload("res://scenes/bots/fighter/Fighter.tscn")


func _fire_other() -> void:
	var proj = _proj.instance()
	proj.global_position = $Muzzle.global_position
	proj.faction = _parent_node.current_faction
	proj.set_level(_parent_node.level_node)
	if proj.has_node("AI") == true:
		proj.get_node("AI").clear_enemies()
	level_node.add_child(proj)
	proj.reset_bot_vars()
	proj.apply_central_impulse(Vector2(1250, 0).rotated(global_rotation))
