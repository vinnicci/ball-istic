extends TileMap


export (bool) var is_destructible: = false
export (float) var health_capacity: = 1000.0
var current_health: float


func take_damage(damage, knockback):
	knockback = Vector2(0,0)
	if is_destructible == false:
		return