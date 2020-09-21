extends "res://scenes/passives/_base/_BasePassive.gd"


const CHARGE_COOLDOWN: float = 0.35
const HEALTH_CAP: float = 25.0
const SHIELD_CAP: float = 25.0
const CHARGE_DMG: float = 0.1
const CHARGE_FORCE: float = 0.16
const SHIELD_RECOVERY: float = 3.5
const HEAT_DISSIPATION: float = 0.6
const SPEED: int = 265
const KNOCKBACK_RESIST: float = 0.1
const TRANSFORM_SPEED: float = 0.07


var _arr_eff: Array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
var _effects: Array = []


func _ready() -> void:
	randomize()


func _apply_effects() -> void:
	for effect in _effects:
		_pick_effect(effect)


func _pick_effect(num: int, positive_eff = 1) -> void:
	match num:
		0: _apply_charge_cooldown(CHARGE_COOLDOWN * positive_eff)
		1: _apply_charge_damage_rate(CHARGE_DMG * positive_eff)
		2: _apply_charge_force(CHARGE_FORCE * positive_eff)
		3: _apply_health_cap(HEALTH_CAP * positive_eff)
		4: _apply_weap_damage_rate(HEAT_DISSIPATION * positive_eff)
		5: _apply_knockback_resist(KNOCKBACK_RESIST * positive_eff)
		6: _apply_shield_cap(SHIELD_CAP * positive_eff)
		7: _apply_shield_regen(SHIELD_RECOVERY * positive_eff)
		8: _apply_speed(SPEED * positive_eff)
		9: _apply_transform_speed(TRANSFORM_SPEED * positive_eff)
