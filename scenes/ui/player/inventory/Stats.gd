extends Control


var _player = null


func set_player(player_node) -> void:
	_player = player_node
	update_stats()


func update_stats() -> void:
	var stats: Dictionary = {
		"Health": _player.current_health_cap,
		"Shield": _player.current_shield_cap,
		"ShieldRecovery": _player.current_shield_recovery,
		"Speed": _player.current_speed,
		"TransformSpeed": _player.current_transform_speed,
		"ChargeCooldown": _player.current_charge_cooldown,
		"ChargeForceFactor": round(_player.current_charge_force_factor * 100),
		"ChargeDmg": round(_player.current_charge_damage_rate * 100),
		"ChargeDmgValue":
			((_player.current_speed * 0.125 * _player.current_charge_force_factor) *
			_player.current_charge_damage_rate),
		"WeaponDmg": round(_player.current_weap_damage_rate * 100),
		"KnockbackResist": round(_player.current_knockback_resist * 100)
	}
	for stat in stats.keys():
		get_node("VBoxContainer/" + stat + "/Val").text = str(stats[stat])


func _process(delta: float) -> void:
	$VBoxContainer/Health/CurrentVal.text = str(_player.get_current_health())
	$VBoxContainer/Shield/CurrentVal.text = str(_player.get_current_shield())
