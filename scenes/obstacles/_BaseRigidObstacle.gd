extends RigidBody2D


export (int) var health_capacity = 1000
export (bool) var destructible = false


func take_damage(damage) -> void:
	if destructible == false:
		return
