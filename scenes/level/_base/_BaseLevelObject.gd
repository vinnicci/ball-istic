extends Node


export (bool) var destructible: = false setget , is_destructible
export (float) var health_capacity: = 1000.0

var _current_health: float setget , get_current_health


func is_destructible():
	return destructible

func get_current_health():
	return _current_health


func take_damage(damage, knockback):
	if destructible == false:
		return
