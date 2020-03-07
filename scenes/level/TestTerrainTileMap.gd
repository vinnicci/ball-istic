extends TileMap

export (bool) var destructible = false
export (int) var health_capacity = 1000

func take_damage(damage):
	if destructible == false:
		return
