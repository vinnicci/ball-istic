extends Control


var _player: Node


func set_player(player_node) -> void:
	_player = player_node
	update_stats()


func update_stats() -> void:
	var stats: Dictionary = {
		"Health": _player.current_health_cap,
		"Shield": _player.current_shield_cap,
		"ShieldRegen": _player.current_shield_regen,
		"Speed": _player.current_speed,
		"TransformSpeed": _player.current_transform_speed,
		"ChargeCooldown": _player.current_charge_cooldown,
		"ChargeForceMult": round(_player.current_charge_force_mult * 100),
		"ChargeDmg": round(_player.current_charge_dmg_rate * 100),
		"ChargeDmgValue":
			round((_player.current_speed * 0.125 * _player.current_charge_force_mult) *
			_player.current_charge_dmg_rate),
		"WeaponDmg": round(_player.current_weap_dmg_rate * 100),
		"DmgResist": round(_player.current_dmg_resist * 100),
		"KnockbackResist": round(_player.current_knockback_resist * 100)
	}
	for stat in stats.keys():
		get_node("VBoxContainer/" + stat + "/Val").text = str(stats[stat])


func _process(_delta: float) -> void:
	$VBoxContainer/Health/CurrentVal.text = str(_player.get_current_health())
	$VBoxContainer/Shield/CurrentVal.text = str(_player.get_current_shield())
