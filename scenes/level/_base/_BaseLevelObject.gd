extends Node


export (bool) var destructible: bool = false setget , is_destructible
export (float) var health_capacity: float = 1000.0 setget , get_health_capacity

var current_health: float


func is_destructible():
	return destructible

func get_health_capacity():
	return health_capacity


func take_damage(damage, knockback):
	if destructible == false:
		return
