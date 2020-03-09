extends TileMap


export (bool) var is_destructible = false
export (int) var health_capacity = 1000


func take_damage(damage):
	if is_destructible == false:
		return
