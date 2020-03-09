extends StaticBody2D


export (bool) var is_destructible = false


func take_damage(damage):
	if is_destructible == false:
		return
