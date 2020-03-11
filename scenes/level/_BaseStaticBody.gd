extends StaticBody2D


export (bool) var is_destructible = false


func take_damage(damage, knockback):
	knockback = 0
	if is_destructible == false:
		return
