extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _fire_other() -> void:
	var proj = Projectile.instance()
	level_node.add_child(proj)
	level_node.add_bot(proj)
	proj.global_position = $Muzzle.global_position
	proj.faction = _parent_node.current_faction
	proj.set_level(_parent_node.level_node)
	proj.reset_bot_vars()
	var ai = proj.get_node("AI")
	ai.clear_enemies()
	ai.set_master(_parent_node)
	proj.apply_central_impulse(Vector2(1250, 0).rotated(global_rotation))
