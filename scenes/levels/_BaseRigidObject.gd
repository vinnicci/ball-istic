extends RigidBody2D


export (float) var health_capacity: = 1000.0
export (bool) var destructible: = false
export (float) var knockback_resist: = 0.2
var current_health: float


func take_damage(damage, knockback) -> void:
	apply_central_impulse(knockback)
	if destructible == false:
		return
	if current_health - damage > 0:
		current_health -= damage
	if current_health - damage <= 0:
		queue_free()
