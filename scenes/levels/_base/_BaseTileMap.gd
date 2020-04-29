extends TileMap

#be sure to extend
#and attach this to nav node

export (bool) var destructible: = false setget , is_destructible
export (float) var health_capacity: = 1000.0

var _current_health: float


func is_destructible():
	return destructible


func take_damage(damage, knockback):
	if destructible == false:
		return
