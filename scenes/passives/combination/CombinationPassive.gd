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


func _pick_effect(num: int) -> void:
	match num:
		0:
			_apply_charge_cooldown(CHARGE_COOLDOWN)
#			print("charge cooldown much faster")
		1: 
			_apply_charge_damage_rate(CHARGE_DMG)
#			print("charge damage increased")
		2: 
			_apply_charge_force(CHARGE_FORCE)
#			print("charge force increased")
		3: 
			_apply_health_cap(HEALTH_CAP)
#			print("health capacity increased")
		4: 
			_apply_heat_dissipation(HEAT_DISSIPATION)
#			print("heat dissipation increased")
		5: 
			_apply_knockback_resist(KNOCKBACK_RESIST)
#			print("knockback resist increased")
		6: 
			_apply_shield_cap(SHIELD_CAP)
#			print("shield capacity increased")
		7: 
			_apply_shield_recovery(SHIELD_RECOVERY)
#			print("shield recovery increased")
		8: 
			_apply_speed(SPEED)
#			print("speed increased")
		9: 
			_apply_transform_speed(TRANSFORM_SPEED)
#			print("transform speed much faster")
