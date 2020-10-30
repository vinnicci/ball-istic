extends "res://scenes/weapons/_base/_BaseWeapon.gd"


onready var _energy_sprite = $Sprite/Energy


func _process(_delta: float) -> void:
	if _timer_charge_cancel_timer.is_stopped() == false:
		_energy_sprite.modulate.a = current_heat / heat_cap
	else:
		_energy_sprite.modulate.a = 0


func _modify_proj(proj_pack) -> Node:
	var proj = ._modify_proj(proj_pack)
	proj.proj_range = rand_range(700, 4000)
	return proj


func _charge_fire() -> void:
	._charge_fire()
	_fire_auto()
