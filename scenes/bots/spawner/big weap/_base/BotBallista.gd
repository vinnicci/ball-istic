extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _fire_other() -> void:
	var proj = Projectile.instance()
	_level_node.add_bot(proj)
	proj.shield_cap = 25 * _parent_node.current_weap_dmg_rate
	proj.health_cap = 25 * _parent_node.current_weap_dmg_rate
	proj.weap_dmg_rate = _parent_node.current_weap_dmg_rate
	proj.charge_dmg_rate += 0.05 * _parent_node.current_weap_dmg_rate
	proj.global_position = $Muzzle.global_position
	proj.faction = _parent_node.current_faction
	proj.reset_bot_vars()
	var ai = proj.get_node("AI")
	ai.clear_enemies()
	ai.set_master(_parent_node)
	proj.apply_central_impulse(Vector2(1250, 0).rotated(global_rotation))
