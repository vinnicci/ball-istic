extends TileMap

#be sure to extend
#and attach this to nav node

export (bool) var is_destructible: = false
export (float) var health_capacity: = 1000.0
var current_health: float


func take_damage(damage, knockback):
	if is_destructible == false:
		return
